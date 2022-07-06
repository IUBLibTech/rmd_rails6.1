class ServicesController < ApplicationController
  include BasicAuthenticationHelper
  # Since this is an API, use :null_session instead of the rails default token.
  protect_from_forgery with: :null_session
  before_action :authenticate

  def access_determination
    aid = params[:avalon_identifier]
    render json: avalon_item_access_hash(AvalonItem.where(avalon_id: aid).first)
  end

  # json response given a barcode what the access decision is for the recording
  # get /services/access_decision_by_barcode/:mdpi_barcode
  def access_decision_by_barcode
    bc = params[:mdpi_barcode]
    recording = Recording.where(mdpi_barcode: bc).first
    render json: recording_json_hash(recording).to_json
  end

  # Note: access decision (singular) by barcodes (plural)
  # action reads the post body which should contain a JSON array of MDPI barcodes
  def access_decision_by_barcodes
    response = {}
    status = 200
    success = true
    ad = []
    begin
      bcs = JSON.parse(request.body.read)
      bcs.each do |bc|
        if ApplicationHelper.valid_barcode? bc
          recording = Recording.where(mdpi_barcode: bc.to_i).first
          response[bc] = recording_json_hash(recording)
          success &&= !recording.nil?
          ad << recording.access_determination
        else
          response[:bc] = recording_json_hash(nil)
          success = false
        end
      end
    rescue => e
      msg = e.message
      bt = e.backtrace.join("\n")
      logger.error msg
      logger.error bt
      response = {"errorMessage": "#{e.message}}"}
      status = 500
    end
    if success
      response[:status] = "success"
      response[:accessDecision] = Recording.most_restrictive_access(ad)
    end
    render json: response.to_json, status: status
  end

  # json response containing access decisions for ALL records in RMD
  # get '/services/access_decisions_by_barcodes'
  def access_decisions_by_barcodes
    render json: Recording.all.pluck(:mdpi_barcode, :access_determination).as_json
  end

  # json response containing a fedora id (a work, not a recording) mapped to the aggregate decision
  # of the works constituent recordings
  #
  def access_decision_by_fedora_id
    r = Recording.where(fedora_item_id: params[:fid])
    if r.size == 0
      render json: {status: "error", fedora_id: params[:fid], msg: "Could not find a Recording(s) with Fedora ID: #{params[:fid]}"}
    else
      render json: {status: "success", fedora_id: params[:fid], msg: "Need to calculate most restrictive access for items with Fedora ID: #{params[:fid]}"}
    end
  end

  def access_decisions_by_fedora_ids

  end

  private
  def no_recording_msg(bc)
    {status: "error", mdpi_barcode: bc, msg: "Could not find a Recording with MDPI barcode #{bc}"}
  end

  def access_decision_msg(r)
    {status: "success", mdpi_barcode: r.mdpi_barcode, access_decision: r.access_determination}
  end

  def recording_json_hash(recording)
    response = {}
    if recording
      response[:status] = "success"
      response[:mdpiBarcode] = "#{recording.mdpi_barcode}"
      response[:accessDecision] = "#{recording.access_determination}"
    else
      response[:status] = "failure"
      response[:mdpi_barcode] = "#{params[:mdpi_barcode]}"
      response[:errorMessage] = "RMD could not find a record with MDPI Barcode: "+params[:mdpi_barcode]
    end
    response
  end


  def avalon_item_access_hash(avalon_item)
    response = {}
    if avalon_item
      response[:status] = "success"
      response[:avalon_identifier] = avalon_item.avalon_id
      response[:accessDetermination] = AccessDeterminationHelper.avalon_access_level(avalon_item.access_determination)
      response[:rmd_url] = request.base_url+"/avalon_items/"+avalon_item.id.to_s
    else
      response[:status] = "failure"
      response[:avalon_identifier] = "#{params[:avalon_identifier]}"
      response[:errorMessage] = "RMD could not find an Avalon Item based on the provided identifier: #{params[:avalon_identifier]}"
    end
    response
  end

end
