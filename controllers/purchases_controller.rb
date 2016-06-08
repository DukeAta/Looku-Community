class PurchasesController < ApplicationController
  before_filter :authenticate_user!, except: [:hook, :show, :paypal_ipn]

  def index
    purchases = current_user.purchases.includes(:document).where(:status => ['completed', 'COMPLETED', 'Completed'])
    @purchases = []
    purchases.each do |purchase|
      if purchase.calculate_days_of_purcharse <= purchase.document.life_time_category
        @purchases << purchase
      end
    end
    if @purchases.present?
      @document_ids = @purchases.collect(&:document_id)
      @documents = Document.where(:id => @document_ids)
    else
      @documents = []
    end
  end

  def create
    purchase = Purchase.where(document_id: purchase_params[:document_id],
      user_id: purchase_params[:user_id])
    if purchase.exists?
      @purchase = purchase.first
      @purchase.update_attributes(updated_at: purchase_params[:updated_at])
    else
      @purchase = Purchase.create(purchase_params)
    end
    #document = Document.where(purchase_params[:document_id]).first
    document = @purchase.document
    price = document.price
    admin_percentage = Purchase::ADMIN_PERCENTAGE

    @api = PayPal::SDK::AdaptivePayments.new
    @pay = @api.build_pay({
        :actionType => "PAY",
        :cancelUrl => root_url,
        :returnUrl => root_url,
        :currencyCode => "USD",
        :feesPayer => "PRIMARYRECEIVER",
        :ipnNotificationUrl => ipn_notify_url(@purchase.id),
        :receiverList => {
          :receiver => [
            {
              :amount => price,
              :email => document.user.paypal_account, #account of owner
              #:email => "kamsolorg+12@gmail.com", #account of owner
              :primary => true
            },
            {
              :amount => price * admin_percentage,
              :email => "omerpucit-facilitator@gmail.com", #account of admin
              :primary => false
            }
          ]
        },
        :memo => "Transaction for #{document.title}"
      } || default_api_value)

    #p @pay
    #exit

    @pay_response = @api.pay(@pay)

    if @pay_response.success?
      redirect_to @api.payment_url(@pay_response) and return
    else
      @pay_response.error
      #redirect_to root_path, alert: "Something went wrong. Please contact support." and return
      redirect_to root_path, alert: "Document owner did not completed with paypal account." and return
    end
  end

  def show
    @purchase = Purchase.find(params[:id])
  end

  protect_from_forgery except: [:hook, :paypal_ipn]

  def paypal_ipn

    if PayPal::SDK::Core::API::IPN.valid?(request.raw_post)

      params.permit! # Permit all Paypal input params
      status = params[:status]
      if status == "Completed" or status.downcase == "completed"
        @purchase = Purchase.find params[:purchase_id]
        transaction_id = if params[:txn_id].present?
          params[:txn_id]
        else
          ""
        end
        @purchase.update_attributes status: status, transaction_id: transaction_id, purchased_at: Time.now
        @purchase.update_attributes notification_params: params
      end

      #logger.info("IPN message: VERIFIED")
      render :text => "VERIFIED"
    else
      #logger.info("IPN message: INVALID")
      render :text => "INVALID"
    end

  end

  def hook
    params.permit! # Permit all Paypal input params
    status = params[:payment_status]
    if status == "Completed"
      @purchase = Purchase.find params[:invoice]
      @purchase.update_attributes notification_params: params, status: status, transaction_id: params[:txn_id], purchased_at: Time.now
    end
    render nothing: true
  end

  private
  def purchase_params
    params.require(:purchase).permit(:user_id, :document_id, :updated_at)
  end
end