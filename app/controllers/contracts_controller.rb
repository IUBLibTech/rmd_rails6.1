class ContractsController < ApplicationController
  before_action :set_contract, except: [:ajax_new, :new, :create, :ajax_create]


  def ajax_show
    render partial: 'avalon_items/contract_show', locals: {c: @contract}
  end
  def ajax_edit
    render partial: 'avalon_items/contract_form'
  end
  def ajax_new
    @contract = Contract.new(avalon_item_id: params[:ai_id])
    render partial: 'avalon_items/contract_form'
  end
  def ajax_create
    @contract = Contract.new(contract_params)
    if @contract.save
      render partial: 'avalon_items/contract_show', locals: {c: @contract}
    else
      render text: 'failed', status: 501
    end
  end

  def new

  end

  def create
    contract = Contract.new(contract_params)
    respond_to do |format|
      if contract.save!
        format.js
      else
        render text: "failure", status: 501
      end
    end
  end

  def edit

  end
  def update
    if @contract.update(contract_params)
      render partial: "avalon_items/contract_show", locals: {c: @contract}
    else
      render text: "failed", status: 501
    end
  end

  def destroy
    if @contract.destroy
      respond_to do |format|
        format.html
        format.js { render text: "success" }
      end
    else
      respond_to do |format|
        format.html
        format.js { render text: "failed", status: 501 }
      end
    end
  end

  private
  def set_contract
    @contract = Contract.find params[:id]
  end
  def contract_params
    params.require(:contract).permit(
      :avalon_item_id, :date_edtf_text, :contract_type, :notes, :perpetual, :id
    )
  end

end
