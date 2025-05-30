# frozen_string_literal: true

class WebhookEndpointPolicy < ApplicationPolicy
  def index?
    verify_permissions!('webhook-endpoint.read')
    verify_environment!(
      strict: false,
    )

    case bearer
    in role: Role(:admin | :developer | :read_only | :environment)
      allow!
    in role: Role(:product) if record.all? { _1.product == bearer }
      allow!
    else
      deny!
    end
  end

  def show?
    verify_permissions!('webhook-endpoint.read')
    verify_environment!(
      strict: false,
    )

    case bearer
    in role: Role(:admin | :developer | :read_only | :environment)
      allow!
    in role: Role(:product) if record.product == bearer
      allow!
    else
      deny!
    end
  end

  def create?
    verify_permissions!('webhook-endpoint.create')
    verify_environment!

    case bearer
    in role: Role(:admin | :developer | :environment)
      allow!
    in role: Role(:product) if record.product == bearer
      allow!
    else
      deny!
    end
  end

  def update?
    verify_permissions!('webhook-endpoint.update')
    verify_environment!

    case bearer
    in role: Role(:admin | :developer | :environment)
      allow!
    in role: Role(:product) if record.product == bearer
      allow!
    else
      deny!
    end
  end

  def destroy?
    verify_permissions!('webhook-endpoint.delete')
    verify_environment!

    case bearer
    in role: Role(:admin | :developer | :environment)
      allow!
    in role: Role(:product) if record.product == bearer
      allow!
    else
      deny!
    end
  end
end
