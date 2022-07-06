class CollectionsController < ApplicationController
  include AccessDeterminationHelper

  def index
    @collection_names = AvalonItem.where(pod_unit: UnitsHelper.human_readable_units_search(User.current_username)).order(:collection).group(:collection).count
  end

  def assign_access
    selected = params[:collections]&.keys

    if !selected || selected.size == 0
      flash.now[:warning] = "<p>You did not select any Collections</p>".html_safe
    elsif selected.size > 0
      if params[:access].blank? && params[:contract_type].blank? && params[:note].blank?
        flash.now[:warning] = "<p>You must specify at least an Access Determination, Contract Type, and/or Note</p>".html_safe
      else
        AvalonItem.transaction do
          ais = User.user_collection_ais(selected)
          @bad_ais = []
          @a =  process_access(ais)
          @b = process_legal_agreement(ais)
          @c = process_note(ais)
          if @a || @b || @c
            ais.each do |ai|
              ai.save!
            end
          end
        end
        if @bad_ais.size > 0
          flash.now[:warning] = "" if flash.now[:warning].nil?
          flash.now[:warning] << "<p>The following avalon items could not have their access determination set because it would be <b><i>less restrictive</i></b> than set by the copyright librarian</p>".html_safe
          flash.now[:warning] << "<p>#{@bad_ais.collect { |ba| ba.title }.join(" | ")}</p>".html_safe
        end
        if @a
          create_flash_now_notice
          flash.now[:notice] << "<p>The access determination was updated for all avalon items in the selected collection(s)</p>".html_safe
        end
        if @b
          create_flash_now_notice
          flash.now[:notice] << "<p>The specified legal agreement has been added to all avalon items in the selected collection(s)</p>".html_safe
        end
        if @c
          create_flash_now_notice
          flash.now[:notice] << "<p>The specified note was added to all avalon items in the selected collection(s)</p>".html_safe
        end
      end
    end



    @collection_names = AvalonItem.where(pod_unit: UnitsHelper.human_readable_units_search(User.current_username)).order(:collection).group(:collection).count
    render "index"
  end
  def collection_list
    @avalon_items = User.user_collection_ais(params[:collection_name])
    @people = []
    @works = []
    render 'nav/search'
  end

  private
  # parses the params hash and if an access determination is present, assigned it to the list of avalon_items, barring
  # any business logic rules, and returns true. Returns false if no access determination is present in the params hash or
  # an access determination could not be created because of business logic rules.
  def process_access(avalon_items)
    # lots to be done here: first check that collection manager is not trying to set access wider than copyright librarian has set
    unless params[:access].blank?
      @access = PastAccessDecision.new(decision: params[:access], changed_by: User.current_username, copyright_librarian: false)
      avalon_items.each do |ai|
        begin
          pad = @access.dup
          last = ai.last_copyright_librarian_access_decision
          # this comparison currently raises an exception when the access determination is less restrictive
          # FIXME: change this so that it returns true/false and does not raise the exception
          if last.nil? || is_more_restrictive_than?(pad, last)
            pad.avalon_item = ai
            ai.current_access_determination = pad
            ai.clear_all_reasons
            if pad.decision == AccessDeterminationHelper::RESTRICTED_ACCESS
              ai.reason_feature_film = !params[:restricted][:reason_feature_film].nil?
              ai.reason_licensing_restriction = !params[:restricted][:reason_licensing_restriction].nil?
              ai.reason_ethical_privacy_considerations = !params[:restricted][:reason_ethical_privacy_considerations].nil?
            elsif pad.decision == AccessDeterminationHelper::WORLD_WIDE_ACCESS
              ai.reason_iu_owned_produced = !params[:worldwide][:reason_iu_owned_produced].nil?
              ai.reason_public_domain = !params[:worldwide][:reason_public_domain].nil?
            ai.reason_license = !params[:worldwide][:reason_license].nil?
            elsif pad.decision == AccessDeterminationHelper::IU_ACCESS
              ai.reason_in_copyright = !params[:iu].nil? && !params[:iu][:reason_in_copyright].nil?
            end
            if pad.decision == AccessDeterminationHelper::DEFAULT_ACCESS
              ai.review_state = AccessDeterminationHelper::DEFAULT_ACCESS
            else
              ai.review_state = AvalonItem::REVIEW_STATE_ACCESS_DETERMINED
            end
            pad.save
          end
        rescue => e
          @bad_ais << ai
        end
      end
      true
    else
      false
    end
  end

  def process_legal_agreement(avalon_items)
    unless params[:contract_type].blank?
      @contract = Contract.new(
        contract_type: params[:contract_type],
        date_edtf_text: (params[:end_date].blank? ? nil : params[:end_date]),
        perpetual: params[:perpetual].blank? ? nil : params[:perpetual],
        notes: params[:agreement_notes].blank? ? nil : params[:agreement_notes])

      avalon_items.each do |ai|
        con = @contract.dup
        con.avalon_item = ai
        con.save
      end
    end
  end

  def process_note(avalon_items)
    unless params[:note].blank?
      @note = AvalonItemNote.new(text: params[:note], creator: User.current_username)
      avalon_items.each do |ai|
        note = @note.dup
        note.avalon_item = ai
        note.save
      end
    end
  end

  def create_flash_now_notice
    flash.now[:notice] = "" if flash.now[:notice].nil?
  end
end
