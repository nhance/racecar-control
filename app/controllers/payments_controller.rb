class PaymentsController < ApplicationController
  def create
    begin
      @registration = Registration.unscoped.find(params[:registration_id])

      customer = create_customer

      if payment_amount > (@registration.amount_due * 100).to_i
        # Technically a hack, but we don't want to charge the card with an invalid amount.
        flash[:error] = "Amount must be less than total amount due!"
      elsif charge = charge_account(customer)
        flash[:success] = "Your payment has been successfully recorded" if record_payment(charge)
      end
    rescue Stripe::CardError => e
      flash[:error] = e.message
    ensure
      redirect_to registration_path(@registration)
    end
  end

  private
  def payment_amount
    params[:amount_in_cents].to_i
  end

  def create_customer
    Stripe::Customer.create(email: current_driver.email, card: params[:stripeToken])
  end

  def charge_account(customer)
    Stripe::Charge.create(customer: customer.id,
                          amount: payment_amount,
                          description: "[#{@registration.event.abbr}] - #{@registration})",
                          currency: 'usd')
  end

  def record_payment(charge)
    @registration.payments.create(amount_paid_in_cents: payment_amount, driver: current_driver, stripe_charge_id: charge.id)
  end
end
