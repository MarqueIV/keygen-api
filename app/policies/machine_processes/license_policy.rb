# frozen_string_literal: true

module MachineProcesses
  class LicensePolicy < ApplicationPolicy
    authorize :machine_process

    def show?
      verify_permissions!('license.read')
      verify_environment!(
        strict: false,
      )

      case bearer
      in role: Role(:admin | :developer | :sales_agent | :support_agent | :read_only | :environment)
        allow!
      in role: Role(:product) if machine_process.product == bearer
        allow!
      in role: Role(:user) if machine_process.owner == bearer || machine_process.license.owner == bearer || bearer.machines.exists?(machine_process.machine_id)
        allow!
      in role: Role(:license) if machine_process.license == bearer
        allow!
      else
        deny!
      end
    end
  end
end
