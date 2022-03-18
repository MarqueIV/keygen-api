# frozen_string_literal: true

module Api::V1::Machines::Actions
  class CheckoutsController < Api::V1::BaseController
    before_action :scope_to_current_account!
    before_action :require_active_subscription!
    before_action :authenticate_with_token!
    before_action :set_machine

    def checkout
      authorize machine

      kwargs = checkout_query.merge(checkout_meta)
                             .symbolize_keys
                             .slice(
                               :include,
                               :encrypt,
                               :ttl,
                              )

      file = MachineCheckoutService.call(
        account: current_account,
        machine: machine,
        **kwargs,
      )

      BroadcastEventService.call(
        event: 'machine.checkout',
        account: current_account,
        resource: machine,
      )

      response.headers['Content-Disposition'] = %(attachment; filename="machine+#{machine.id}.lic")
      response.headers['Content-Type']        = 'application/octet-stream'

      render body: file
    rescue MachineCheckoutService::InvalidIncludeError => e
      render_bad_request detail: e.message, code: :CHECKOUT_INCLUDE_INVALID, source: { parameter: :include }
    rescue MachineCheckoutService::InvalidTTLError => e
      render_bad_request detail: e.message, code: :CHECKOUT_TTL_INVALID, source: { parameter: :ttl }
    rescue MachineCheckoutService::InvalidAlgorithmError => e
      render_unprocessable_entity detail: e.message
    end

    private

    attr_reader :machine

    def set_machine
      scoped_machines = policy_scope(current_account.machines)

      @machine = FindByAliasService.call(scope: scoped_machines, identifier: params[:id], aliases: :fingerprint)

      Current.resource = machine
    end

    typed_parameters do
      options strict: true

      on :checkout do
        if current_bearer&.has_role?(:admin, :developer, :sales_agent, :support_agent, :product)
          param :meta, type: :hash, optional: true do
            param :include, type: :array, optional: true
            param :encrypt, type: :boolean, optional: true
            param :ttl, type: :integer, optional: true
          end
        end
      end
    end

    typed_query do
      on :checkout do
        if current_bearer&.has_role?(:admin, :developer, :sales_agent, :support_agent, :product)
          param :include, type: :array, coerce: true, optional: true
          param :encrypt, type: :boolean, coerce: true, optional: true
          param :ttl, type: :integer, coerce: true, optional: true
        end
      end
    end
  end
end