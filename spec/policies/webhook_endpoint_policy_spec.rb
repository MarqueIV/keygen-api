# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

describe WebhookEndpointPolicy, type: :policy do
  subject { described_class.new(record, account:, environment:, bearer:, token:) }

  with_role_authorization :admin do
    with_scenarios %i[accessing_webhook_endpoints] do
      with_token_authentication do
        with_permissions %w[webhook-endpoint.read] do
          without_token_permissions { denies :index }

          allows :index
        end

        with_wildcard_permissions { allows :index }
        with_default_permissions  { allows :index }
        without_permissions       { denies :index }

        within_environment :isolated do
          with_bearer_and_token_trait :in_shared_environment do
            denies :index
          end

          with_bearer_and_token_trait :in_nil_environment do
            denies :index
          end

          allows :index
        end

        within_environment :shared do
          with_bearer_and_token_trait :in_isolated_environment do
            denies :index
          end

          with_bearer_and_token_trait :in_nil_environment do
            allows :index
          end

          allows :index
        end

        within_environment nil do
          with_bearer_and_token_trait :in_isolated_environment do
            denies :index
          end

          with_bearer_and_token_trait :in_shared_environment do
            denies :index
          end

          allows :index
        end
      end
    end

    with_scenarios %i[accessing_a_webhook_endpoint] do
      with_token_authentication do
        with_permissions %w[webhook-endpoint.read] do
          without_token_permissions { denies :show }

          allows :show
        end

        with_permissions %w[webhook-endpoint.create] do
          without_token_permissions { denies :create }

          allows :create
        end

        with_permissions %w[webhook-endpoint.update] do
          without_token_permissions { denies :update }

          allows :update
        end

        with_permissions %w[webhook-endpoint.delete] do
          without_token_permissions { denies :destroy }

          allows :destroy
        end

        with_wildcard_permissions do
          without_token_permissions do
            denies :show, :create, :update, :destroy
          end

          allows :show, :create, :update, :destroy
        end

        with_default_permissions do
          without_token_permissions do
            denies :show, :create, :update, :destroy
          end

          allows :show, :create, :update, :destroy
        end

        without_permissions do
          denies :show, :create, :update, :destroy
        end

        within_environment :isolated do
          with_bearer_and_token_trait :in_shared_environment do
            denies :show, :create, :update, :destroy
          end

          with_bearer_and_token_trait :in_nil_environment do
            denies :show, :create, :update, :destroy
          end

          allows :show, :create, :update, :destroy
        end

        within_environment :shared do
          with_bearer_and_token_trait :in_isolated_environment do
            denies :show, :create, :update, :destroy
          end

          with_bearer_and_token_trait :in_nil_environment do
            allows :show, :create, :update, :destroy
          end

          allows :show, :create, :update, :destroy
        end

        within_environment nil do
          with_bearer_and_token_trait :in_isolated_environment do
            denies :show, :create, :update, :destroy
          end

          with_bearer_and_token_trait :in_shared_environment do
            denies :show, :create, :update, :destroy
          end

          allows :show, :create, :update, :destroy
        end
      end
    end
  end

  with_role_authorization :environment do
    within_environment :self do
      with_scenarios %i[accessing_webhook_endpoints] do
        with_token_authentication do
          with_permissions %w[webhook-endpoint.read] do
            without_token_permissions { denies :index }

            allows :index
          end

          with_wildcard_permissions { allows :index }
          with_default_permissions  { allows :index }
          without_permissions       { denies :index }

          within_environment :isolated do
            with_bearer_and_token_trait :isolated do
              allows :index
            end

            with_bearer_and_token_trait :shared do
              denies :index
            end
          end

          within_environment :shared do
            with_bearer_and_token_trait :isolated do
              denies :index
            end

            with_bearer_and_token_trait :shared do
              allows :index
            end
          end

          within_environment nil do
            with_bearer_and_token_trait :isolated do
              denies :index
            end

            with_bearer_and_token_trait :shared do
              denies :index
            end
          end
        end
      end

      with_scenarios %i[accessing_a_webhook_endpoint] do
        with_token_authentication do
          with_permissions %w[webhook-endpoint.read] do
            without_token_permissions { denies :show }

            allows :show
          end

          with_permissions %w[webhook-endpoint.create] do
            without_token_permissions { denies :create }

            allows :create
          end

          with_permissions %w[webhook-endpoint.update] do
            without_token_permissions { denies :update }

            allows :update
          end

          with_permissions %w[webhook-endpoint.delete] do
            without_token_permissions { denies :destroy }

            allows :destroy
          end

          with_wildcard_permissions do
            without_token_permissions do
              denies :show, :create, :update, :destroy
            end

            allows :show, :create, :update, :destroy
          end

          with_default_permissions do
            without_token_permissions do
              denies :show, :create, :update, :destroy
            end

            allows :show, :create, :update, :destroy
          end

          without_permissions do
            denies :show, :create, :update, :destroy
          end

          within_environment :isolated do
            with_bearer_and_token_trait :isolated do
              allows :show, :create, :update, :destroy
            end

            with_bearer_and_token_trait :shared do
              denies :show, :create, :update, :destroy
            end
          end

          within_environment :shared do
            with_bearer_and_token_trait :isolated do
              denies :show, :create, :update, :destroy
            end

            with_bearer_and_token_trait :shared do
              allows :show, :create, :update, :destroy
            end
          end

          within_environment nil do
            with_bearer_and_token_trait :isolated do
              denies :show, :create, :update, :destroy
            end

            with_bearer_and_token_trait :shared do
              denies :show, :create, :update, :destroy
            end
          end
        end
      end
    end
  end

  with_role_authorization :product do
    with_scenarios %i[accessing_its_webhook_endpoints] do
      with_token_authentication do
        with_permissions %w[webhook-endpoint.read] do
          without_token_permissions { denies :index }

          allows :index
        end

        with_wildcard_permissions { allows :index }
        with_default_permissions  { allows :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_its_webhook_endpoint] do
      with_token_authentication do
        with_permissions %w[webhook-endpoint.read] do
          without_token_permissions { denies :show }

          allows :show
        end

        with_permissions %w[webhook-endpoint.create] do
          without_token_permissions { denies :create }

          allows :create
        end

        with_permissions %w[webhook-endpoint.update] do
          without_token_permissions { denies :update }

          allows :update
        end

        with_permissions %w[webhook-endpoint.delete] do
          without_token_permissions { denies :destroy }

          allows :destroy
        end

        with_wildcard_permissions do
          without_token_permissions do
            denies :show, :create, :update, :destroy
          end

          allows :show, :create, :update, :destroy
        end

        with_default_permissions do
          without_token_permissions do
            denies :show, :create, :update, :destroy
          end

          allows :show, :create, :update, :destroy
        end

        without_permissions do
          denies :show, :create, :update, :destroy
        end
      end
    end

    with_scenarios %i[accessing_webhook_endpoints] do
      with_token_authentication do
        with_permissions %w[webhook-endpoint.read] do
          denies :index
        end

        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_a_webhook_endpoint] do
      with_token_authentication do
        with_permissions %w[webhook-endpoint.read] do
          denies :show
        end

        with_permissions %w[webhook-endpoint.create] do
          denies :create
        end

        with_permissions %w[webhook-endpoint.update] do
          denies :update
        end

        with_permissions %w[webhook-endpoint.delete] do
          denies :destroy
        end

        with_wildcard_permissions do
          denies :show, :create, :update, :destroy
        end

        with_default_permissions do
          denies :show, :create, :update, :destroy
        end

        without_permissions do
          denies :show, :create, :update, :destroy
        end
      end
    end
  end

  with_role_authorization :license do
    with_scenarios %i[accessing_webhook_endpoints] do
      with_license_authentication do
        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end

      with_token_authentication do
        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_a_webhook_endpoint] do
      with_license_authentication do
        with_wildcard_permissions do
          denies :show, :create, :update, :destroy
        end

        with_default_permissions do
          denies :show, :create, :update, :destroy
        end

        without_permissions do
          denies :show, :create, :update, :destroy
        end
      end

      with_token_authentication do
        with_wildcard_permissions do
          denies :show, :create, :update, :destroy
        end

        with_default_permissions do
          denies :show, :create, :update, :destroy
        end

        without_permissions do
          denies :show, :create, :update, :destroy
        end
      end
    end
  end

  with_role_authorization :user do
    with_scenarios %i[accessing_webhook_endpoints] do
      with_token_authentication do
        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_a_webhook_endpoint] do
      with_token_authentication do
        with_wildcard_permissions do
          denies :show, :create, :update, :destroy
        end

        with_default_permissions do
          denies :show, :create, :update, :destroy
        end

        without_permissions do
          denies :show, :create, :update, :destroy
        end
      end
    end
  end

  without_authorization do
    with_scenarios %i[accessing_webhook_endpoints] do
      without_authentication do
        denies :index
      end
    end

    with_scenarios %i[accessing_a_webhook_endpoint] do
      without_authentication do
        denies :show, :create, :update, :destroy
      end
    end
  end
end
