# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

describe Licenses::TokenPolicy, type: :policy do
  subject { described_class.new(record, account:, environment:, bearer:, token:, license:) }

  with_role_authorization :admin do
    with_scenarios %i[accessing_a_license accessing_its_tokens] do
      with_token_authentication do
        with_permissions %w[token.read] do
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

    with_scenarios %i[accessing_a_license accessing_its_token] do
      with_token_authentication do
        with_permissions %w[token.read] do
          without_token_permissions { denies :show }

          allows :show
        end

        with_permissions %w[license.tokens.generate] do
          without_token_permissions { denies :create }

          allows :create
        end

        with_wildcard_permissions do
          without_token_permissions do
            denies :show, :create
          end

          allows :show, :create
        end

        with_default_permissions do
          without_token_permissions do
            denies :show, :create
          end

          allows :show, :create
        end

        without_permissions do
          denies :show, :create
        end

        within_environment :isolated do
          with_bearer_and_token_trait :in_shared_environment do
            denies :show, :create
          end

          with_bearer_and_token_trait :in_nil_environment do
            denies :show, :create
          end

          allows :show, :create
        end

        within_environment :shared do
          with_bearer_and_token_trait :in_isolated_environment do
            denies :show, :create
          end

          with_bearer_and_token_trait :in_nil_environment do
            allows :show, :create
          end

          allows :show, :create
        end

        within_environment nil do
          with_bearer_and_token_trait :in_isolated_environment do
            denies :show, :create
          end

          with_bearer_and_token_trait :in_shared_environment do
            denies :show, :create
          end

          allows :show, :create
        end
      end
    end

    with_scenarios %i[accessing_another_account accessing_a_license accessing_its_token] do
      with_token_authentication do
        with_permissions %w[token.read] do
          denies :show
        end

        with_permissions %w[license.tokens.generate] do
          denies :create
        end

        with_wildcard_permissions do
          denies :show, :create
        end

        with_default_permissions do
          denies :show, :create
        end

        without_permissions do
          denies :show, :create
        end
      end
    end
  end

  with_role_authorization :environment do
    within_environment :self do
      with_scenarios %i[accessing_a_license accessing_its_tokens] do
        with_token_authentication do
          with_permissions %w[token.read] do
            without_token_permissions { denies :index }

            allows :index
          end

          with_wildcard_permissions { allows :index }
          with_default_permissions  { allows :index }
          without_permissions       { denies :index }
        end
      end

      with_scenarios %i[accessing_a_license accessing_its_token] do
        with_token_authentication do
          with_permissions %w[token.read] do
            without_token_permissions { denies :show }

            allows :show
          end

          with_permissions %w[license.tokens.generate] do
            without_token_permissions { denies :create }

            allows :create
          end

          with_wildcard_permissions do
            allows :show, :create
          end

          with_default_permissions do
            allows :show, :create
          end

          without_permissions do
            denies :show, :create
          end
        end
      end
    end

    with_scenarios %i[accessing_a_license accessing_its_tokens] do
      with_token_authentication do
        with_permissions %w[token.read] do
          without_token_permissions { denies :index }

          denies :index
        end

        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_a_license accessing_its_token] do
      with_token_authentication do
        with_permissions %w[token.read] do
          without_token_permissions { denies :show }

          denies :show
        end

        with_permissions %w[license.tokens.generate] do
          without_token_permissions { denies :create }

          denies :create
        end

        with_wildcard_permissions do
          denies :show, :create
        end

        with_default_permissions do
          denies :show, :create
        end

        without_permissions do
          denies :show, :create
        end
      end
    end
  end

  with_role_authorization :product do
    with_scenarios %i[accessing_its_license accessing_its_tokens] do
      with_token_authentication do
        with_permissions %w[token.read] do
          without_token_permissions { denies :index }

          allows :index
        end

        with_wildcard_permissions { allows :index }
        with_default_permissions  { allows :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_its_license accessing_its_token] do
      with_token_authentication do
        with_permissions %w[token.read] do
          without_token_permissions { denies :show }

          allows :show
        end

        with_permissions %w[license.tokens.generate] do
          without_token_permissions { denies :create }

          allows :create
        end

        with_wildcard_permissions do
          allows :show, :create
        end

        with_default_permissions do
          allows :show, :create
        end

        without_permissions do
          denies :show, :create
        end
      end
    end

    with_scenarios %i[accessing_a_license accessing_its_tokens] do
      with_token_authentication do
        with_permissions %w[token.read] do
          without_token_permissions { denies :index }

          denies :index
        end

        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_a_license accessing_its_token] do
      with_token_authentication do
        with_permissions %w[token.read] do
          without_token_permissions { denies :show }

          denies :show
        end

        with_permissions %w[license.tokens.generate] do
          without_token_permissions { denies :create }

          denies :create
        end

        with_wildcard_permissions do
          denies :show, :create
        end

        with_default_permissions do
          denies :show, :create
        end

        without_permissions do
          denies :show, :create
        end
      end
    end
  end

  with_role_authorization :license do
    with_scenarios %i[accessing_itself accessing_its_tokens] do
      with_token_authentication do
        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_itself accessing_its_token] do
      with_license_authentication do
        with_wildcard_permissions do
          denies :show, :create
        end

        with_default_permissions do
          denies :show, :create
        end

        without_permissions do
          denies :show, :create
        end
      end

      with_token_authentication do
        with_wildcard_permissions do
          denies :show, :create
        end

        with_default_permissions do
          denies :show, :create
        end

        without_permissions do
          denies :show, :create
        end
      end
    end

    with_scenarios %i[accessing_a_license accessing_its_tokens] do
      with_token_authentication do
        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_a_license accessing_its_token] do
      with_license_authentication do
        with_wildcard_permissions do
          denies :show, :create
        end

        with_default_permissions do
          denies :show, :create
        end

        without_permissions do
          denies :show, :create
        end
      end

      with_token_authentication do
        with_wildcard_permissions do
          denies :show, :create
        end

        with_default_permissions do
          denies :show, :create
        end

        without_permissions do
          denies :show, :create
        end
      end
    end
  end

  with_role_authorization :user do
    with_bearer_trait :with_owned_licenses do
      with_scenarios %i[accessing_its_license accessing_its_tokens] do
        with_token_authentication do
          with_wildcard_permissions { denies :index }
          with_default_permissions  { denies :index }
          without_permissions       { denies :index }
        end
      end

      with_scenarios %i[accessing_its_license accessing_its_token] do
        with_token_authentication do
          with_wildcard_permissions do
            denies :show, :create
          end

          with_default_permissions do
            denies :show, :create
          end

          without_permissions do
            denies :show, :create
          end
        end
      end
    end

    with_bearer_trait :with_user_licenses do
      with_scenarios %i[accessing_its_license accessing_its_tokens] do
        with_token_authentication do
          with_wildcard_permissions { denies :index }
          with_default_permissions  { denies :index }
          without_permissions       { denies :index }
        end
      end

      with_scenarios %i[accessing_its_license accessing_its_token] do
        with_token_authentication do
          with_wildcard_permissions do
            denies :show, :create
          end

          with_default_permissions do
            denies :show, :create
          end

          without_permissions do
            denies :show, :create
          end
        end
      end
    end

    with_scenarios %i[accessing_a_license accessing_its_tokens] do
      with_token_authentication do
        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_a_license accessing_its_token] do
      with_token_authentication do
        with_wildcard_permissions do
          denies :show, :create
        end

        with_default_permissions do
          denies :show, :create
        end

        without_permissions do
          denies :show, :create
        end
      end
    end
  end

  without_authorization do
    with_scenarios %i[accessing_a_license accessing_its_tokens] do
      without_authentication do
        denies :index
      end
    end

    with_scenarios %i[accessing_a_license accessing_its_token] do
      without_authentication do
        denies :show, :create
      end
    end
  end
end
