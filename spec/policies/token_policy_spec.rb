# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

describe TokenPolicy, type: :policy do
  subject { described_class.new(record, account:, bearer:, token:) }

  with_role_authorization :admin do
    with_scenarios %i[accessing_tokens] do
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

    with_scenarios %i[accessing_a_token] do
      with_basic_authentication do
        with_permissions %w[token.generate] do
          allows :generate
        end

        with_wildcard_permissions do
          allows :generate
        end

        with_default_permissions do
          allows :generate
        end

        without_permissions do
          denies :generate
        end
      end

      with_token_authentication do
        with_permissions %w[token.read] do
          without_token_permissions { denies :show }

          allows :show
        end

        with_permissions %w[token.generate] do
          without_token_permissions { denies :generate }

          allows :generate
        end

        with_permissions %w[token.regenerate] do
          without_token_permissions { denies :regenerate }

          allows :regenerate
        end

        with_permissions %w[token.revoke] do
          without_token_permissions { denies :revoke }

          allows :revoke
        end

        with_wildcard_permissions do
          without_token_permissions do
            denies :show, :generate, :regenerate, :revoke
          end

          allows :show, :generate, :regenerate, :revoke
        end

        with_default_permissions do
          without_token_permissions do
            denies :show, :generate, :regenerate, :revoke
          end

          allows :show, :generate, :regenerate, :revoke
        end

        without_permissions do
          denies :show, :generate, :regenerate, :revoke
        end
      end
    end

    with_scenarios %i[accessing_another_account accessing_tokens] do
      with_token_authentication do
        with_permissions %w[token.read] do
          denies :index
        end

        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_another_account accessing_a_token] do
      with_token_authentication do
        with_permissions %w[token.read] do
          denies :show
        end

        with_permissions %w[token.generate] do
          denies :generate
        end

        with_permissions %w[token.regenerate] do
          denies :regenerate
        end

        with_permissions %w[token.revoke] do
          denies :revoke
        end

        with_wildcard_permissions do
          denies :show, :generate, :regenerate, :revoke
        end

        with_default_permissions do
          denies :show, :generate, :regenerate, :revoke
        end

        without_permissions do
          denies :show, :generate, :regenerate, :revoke
        end
      end
    end
  end

  with_role_authorization :product do
    with_scenarios %i[accessing_its_tokens] do
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

    with_scenarios %i[accessing_its_token] do
      with_token_authentication do
        with_permissions %w[token.read] do
          without_token_permissions { denies :show }

          allows :show
        end

        with_permissions %w[token.generate] do
          without_token_permissions { denies :generate }

          denies :generate
        end

        with_permissions %w[token.regenerate] do
          without_token_permissions { denies :regenerate }

          allows :regenerate
        end

        with_permissions %w[token.revoke] do
          without_token_permissions { denies :revoke }

          allows :revoke
        end

        with_wildcard_permissions do
          without_token_permissions do
            denies :show, :generate, :regenerate, :revoke
          end

          allows :show, :regenerate, :revoke
          denies :generate
        end

        with_default_permissions do
          without_token_permissions do
            denies :show, :generate, :regenerate, :revoke
          end

          allows :show, :regenerate, :revoke
          denies :generate
        end

        without_permissions do
          denies :show, :generate, :regenerate, :revoke
        end
      end
    end

    with_scenarios %i[accessing_tokens] do
      with_token_authentication do
        with_permissions %w[token.read] do
          denies :index
        end

        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_a_token] do
      with_token_authentication do
        with_permissions %w[token.read] do
          denies :show
        end

        with_permissions %w[token.generate] do
          denies :generate
        end

        with_permissions %w[token.regenerate] do
          denies :regenerate
        end

        with_permissions %w[token.revoke] do
          denies :revoke
        end

        with_wildcard_permissions do
          denies :show, :generate, :regenerate, :revoke
        end

        with_default_permissions do
          denies :show, :generate, :regenerate, :revoke
        end

        without_permissions do
          denies :show, :generate, :regenerate, :revoke
        end
      end
    end
  end

  with_role_authorization :license do
    with_scenarios %i[accessing_its_tokens] do
      with_license_authentication do
        with_permissions %w[token.read] do
          allows :index
        end

        with_wildcard_permissions { allows :index }
        with_default_permissions  { allows :index }
        without_permissions       { denies :index }
      end

      with_token_authentication do
        with_permissions %w[token.read] do
          allows :index
        end

        with_wildcard_permissions { allows :index }
        with_default_permissions  { allows :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_its_token] do
      with_license_authentication do
        with_permissions %w[token.read] do
          allows :show
        end

        with_permissions %w[token.regenerate] do
          allows :regenerate
        end

        with_permissions %w[token.revoke] do
          allows :revoke
        end

        with_wildcard_permissions do
          allows :show, :regenerate, :revoke
          denies :generate
        end

        with_default_permissions do
          allows :show, :regenerate, :revoke
          denies :generate
        end

        without_permissions do
          denies :show, :generate, :regenerate, :revoke
        end
      end

      with_token_authentication do
        with_permissions %w[token.read] do
          without_token_permissions { denies :show }

          allows :show
        end

        with_permissions %w[token.regenerate] do
          without_token_permissions { denies :regenerate }

          allows :regenerate
        end

        with_permissions %w[token.revoke] do
          without_token_permissions { denies :revoke }

          allows :revoke
        end

        with_wildcard_permissions do
          without_token_permissions do
            denies :show, :generate, :regenerate, :revoke
          end

          allows :show, :regenerate, :revoke
          denies :generate
        end

        with_default_permissions do
          without_token_permissions do
            denies :show, :generate, :regenerate, :revoke
          end

          allows :show, :regenerate, :revoke
          denies :generate
        end

        without_permissions do
          denies :show, :generate, :regenerate, :revoke
        end
      end
    end

    with_scenarios %i[accessing_tokens] do
      with_license_authentication do
        with_permissions %w[token.read] do
          denies :index
        end

        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end

      with_token_authentication do
        with_permissions %w[token.read] do
          denies :index
        end

        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_a_token] do
      with_license_authentication do
        with_permissions %w[token.read] do
          denies :show
        end

        with_permissions %w[token.regenerate] do
          denies :regenerate
        end

        with_permissions %w[token.revoke] do
          denies :revoke
        end

        with_wildcard_permissions do
          denies :show, :generate, :regenerate, :revoke
        end

        with_default_permissions do
          denies :show, :generate, :regenerate, :revoke
        end

        without_permissions do
          denies :show, :generate, :regenerate, :revoke
        end
      end

      with_token_authentication do
        with_permissions %w[token.read] do
          denies :show
        end

        with_permissions %w[token.regenerate] do
          denies :regenerate
        end

        with_permissions %w[token.revoke] do
          denies :revoke
        end

        with_wildcard_permissions do
          denies :show, :generate, :regenerate, :revoke
        end

        with_default_permissions do
          denies :show, :generate, :regenerate, :revoke
        end

        without_permissions do
          denies :show, :generate, :regenerate, :revoke
        end
      end
    end
  end

  with_role_authorization :user do
    with_scenarios %i[accessing_its_tokens] do
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

    with_scenarios %i[accessing_its_token] do
      with_basic_authentication do
        with_permissions %w[token.generate] do
          allows :generate
        end

        with_wildcard_permissions do
          allows :generate
        end

        with_default_permissions do
          allows :generate
        end

        without_permissions do
          denies :generate
        end
      end

      with_token_authentication do
        with_permissions %w[token.read] do
          without_token_permissions { denies :show }

          allows :show
        end

        with_permissions %w[token.generate] do
          without_token_permissions { denies :generate }

          allows :generate
        end

        with_permissions %w[token.regenerate] do
          without_token_permissions { denies :regenerate }

          allows :regenerate
        end

        with_permissions %w[token.revoke] do
          without_token_permissions { denies :revoke }

          allows :revoke
        end

        with_wildcard_permissions do
          without_token_permissions do
            denies :show, :generate, :regenerate, :revoke
          end

          allows :show, :generate, :regenerate, :revoke
        end

        with_default_permissions do
          without_token_permissions do
            denies :show, :generate, :regenerate, :revoke
          end

          allows :show, :generate, :regenerate, :revoke
        end

        without_permissions do
          denies :show, :generate, :regenerate, :revoke
        end
      end
    end

    with_scenarios %i[accessing_tokens] do
      with_token_authentication do
        with_permissions %w[token.read] do
          denies :index
        end

        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_a_token] do
      with_token_authentication do
        with_permissions %w[token.read] do
          denies :show
        end

        with_permissions %w[token.regenerate] do
          denies :regenerate
        end

        with_permissions %w[token.revoke] do
          denies :revoke
        end

        with_wildcard_permissions do
          denies :show, :regenerate, :revoke
        end

        with_default_permissions do
          denies :show, :regenerate, :revoke
        end

        without_permissions do
          denies :show, :regenerate, :revoke
        end
      end
    end
  end

  without_authorization do
    with_scenarios %i[accessing_tokens] do
      without_authentication do
        denies :index
      end
    end

    with_scenarios %i[accessing_a_token] do
      without_authentication do
        denies :show, :generate, :regenerate, :revoke
      end
    end
  end
end