class PeopleController < ApplicationController
  before_action :set_person, only: [:show, :edit, :update, :destroy]

  # GET /people
  # GET /people.json
  def index
    @people = Person.where(entity: false).order(:last_name)
    @entities = Person.where(entity: true).order(:company_name)
  end

  # GET /people/1
  # GET /people/1.json
  def show
    #render 'people/_ajax_show'
    render 'people/show'
  end

  # GET /people/new
  def new
    @person = Person.new(entity: false)
  end

  def new_entity
    @person = Person.new(entity: true)
    render 'people/new'
  end

  # GET /people/1/edit
  def edit
  end

  def ajax_edit_person
    render partial: 'people/ajax_edit_person'
  end

  # GET /people/
  def ajax_autocomplete
    @hits = Person.where("last_name like ?", "%#{params[:term]}%")
    render json: @hits
  end

  def ajax_autocomplete_company
    @hits = Person.where("company_name like ?", "%#{params[:term]}%")
    render json: @hits
  end

  # POST /people
  # POST /people.json
  def create
    @person = Person.new(person_params)
    # hidden field tag for entity is sent as text so person_params does not correctly assign it.
    @person.entity = params["entity"] == "true"
    respond_to do |format|
      if @person.save
        if params[:avalon_item_id]
          @avalon_item = AvalonItem.find(params[:avalon_item_id])
          AvalonItemPerson.new(person_id: @person.id, avalon_item_id: params[:avalon_item_id].to_i).save
        end
        format.html { redirect_to people_path }
        format.js {}
        format.json { render :show, status: :created, location: @person }
      else
        format.html { render :new }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /people/1
  # PATCH/PUT /people/1.json
  def update
    respond_to do |format|
      if @person.update(person_params)
        format.html { redirect_to @person, notice: 'Person was successfully updated.' }
        format.json { render :show, status: :ok, location: @person }
      else
        format.html { render :edit }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    respond_to do |format|
      if @person.avalon_items.size + @person.works.size> 0
        format.html { redirect_to people_url, notice: "The Person/Entity <i>#{@person.entity? ? @person.company_name : @person.full_name}</i> could not be destroyed because it is associated with Avalon Items or Works" }
      else
        @person.destroy
        format.html { redirect_to people_url, notice: "The Person/Entity <i>#{@person.entity? ? @person.company_name : @person.full_name}</i> was successfully destroyed." }
      end
    end
  end

  def ajax_new_person
    @person = Person.new(last_name: params[:last_name], first_name: params[:first_name])
    @ajax = true
    render partial: 'people/form'
  end

  def ajax_show
    @person = Person.find(params[:id])
    render partial: 'person/ajax_show'
  end

  def ajax_work_person_form
    @person = Person.find(params[:id])
    render partial: 'ajax_work_person_form'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def person_params
      params.require(:person).permit(
          :first_name, :middle_name, :last_name, :date_of_birth_edtf, :date_of_death_edtf, :place_of_birth,
          :authority_source, :aka, :notes, :authority_source_url, :entity, :company_name, :entity_nationality
      )
    end
end
