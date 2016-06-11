module Api::V1
  class AccountsController < Api::V1::BaseController
    before_action :authenticate_with_token!
    before_action :set_account, only: [:show, :update, :destroy]

    # GET /accounts
    def index
      @accounts = Account.all
      authorize @accounts

      render json: @accounts
    end

    # GET /accounts/1
    def show
      authorize @account

      render json: @account
    end

    # POST /accounts
    def create
      @account = Account.new account_params
      authorize @account

      if @account.save
        render json: @account, status: :created, location: v1_account_url(@account)
      else
        render json: @account, status: :unprocessable_entity, adapter: :json_api, serializer: ActiveModel::Serializer::ErrorSerializer
      end
    end

    # PATCH/PUT /accounts/1
    def update
      authorize @account

      if @account.update(account_params)
        render json: @account
      else
        render json: @account, status: :unprocessable_entity, adapter: :json_api, serializer: ActiveModel::Serializer::ErrorSerializer
      end
    end

    # DELETE /accounts/1
    def destroy
      authorize @account

      @account.destroy
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find_by_hashid params[:id]
    end

    # Only allow a trusted parameter "white list" through.
    def account_params
      params.require(:account).permit :name, :email, :subdomain, :plan
    end
  end
end
