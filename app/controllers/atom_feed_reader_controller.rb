class AtomFeedReaderController < ApplicationController
  include AvalonItemsHelper
  before_action :set_atom_feed_read, only: [:read_json, :load_avalon_record]

  def index
      @atom_feed_reads = AtomFeedRead.where(successfully_read: false).order('avalon_last_updated ASC').limit(100)
  end

  # action for pre loading the first (oldest) recordings in MCO
  def prepopulate
    # AtomFeedReaderHelper.prepopulate
    # @atom_feed_reads = AtomFeedRead.where(successfully_read: false).order('avalon_last_updated ASC')
    # render 'atom_feed_reader/index'
    AtomFeedReaderTask.new.perform
  end

  # action for triggering a check to see if there are new recordings since the last read in
  def read_current
    # AtomFeedReaderHelper.read_current
    # @atom_feed_reads = AtomFeedRead.where(successfully_read: false).order('avalon_last_updated ASC')
    # render 'atom_feed_reader/index'
  end

  def search
    @atom_feed_reads = AtomFeedRead.where("title like '%#{params[:search]}%'")
    render :index
  end

  def load_avalon_record
    # json_text = AtomFeedReaderHelper.read_avalon_json(@atom_feed_read.json_url)
    # avalon_item = save_json(json_text)
    # if avalon_item.nil?
    #   flash[:warning] = "Could not find any Recordings in MCO from URL #{@atom_feed_read.json_url}"
    #   redirect_to avalon_items_path
    # else
    #   flash[:notice] = "New record(s) were loaded into RMD"
    #   redirect_to avalon_item_path(avalon_item)
    # end
    JsonReaderTask.new.perform
  end

  def read_json
    atom_feed_read = AtomFeedRead.find(params[:id])
    @json = AtomFeedReaderHelper.read_avalon_json(atom_feed_read.json_url)
    @json = JSON.parse(@json)
    render 'atom_feed_reader/json'
  end

  private
  def set_atom_feed_read
    @atom_feed_read = AtomFeedRead.find(params[:id])
  end

end
