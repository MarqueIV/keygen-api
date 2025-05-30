# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

describe Machine, type: :model do
  let(:account) { create(:account) }

  it_behaves_like :environmental
  it_behaves_like :accountable

  describe '#environment=', only: :ee do
    context 'on create' do
      it 'should apply default environment matching license' do
        environment = create(:environment, account:)
        license     = create(:license, account:, environment:)
        machine     = create(:machine, account:, license:)

        expect(machine.environment).to eq license.environment
      end

      it 'should not raise when environment matches license' do
        environment = create(:environment, account:)
        license     = create(:license, account:, environment:)

        expect { create(:machine, account:, environment:, license:) }.to_not raise_error
      end

      it 'should raise when environment does not match license' do
        environment = create(:environment, account:)
        license     = create(:license, account:, environment: nil)

        expect { create(:machine, account:, environment:, license:) }.to raise_error ActiveRecord::RecordInvalid
      end
    end

    context 'on update' do
      it 'should not raise when environment matches license' do
        environment = create(:environment, account:)
        machine     = create(:machine, account:, environment:)

        expect { machine.update!(license: create(:license, account:, environment:)) }.to_not raise_error
      end

      it 'should raise when environment does not match license' do
        environment = create(:environment, account:)
        machine     = create(:machine, account:, environment:)

        expect { machine.update!(license: create(:license, account:, environment: nil)) }.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end

  describe '#license=' do
    context 'on build' do
      it 'should denormalize policy from unpersisted license' do
        policy  = build(:policy, account:)
        license = build(:license, policy:, account:)
        machine = build(:machine, license:, account:)

        expect(machine.policy_id).to be_nil
        expect(machine.policy).to eq policy
      end

      it 'should denormalize policy from persisted license' do
        license = create(:license, account:)
        machine = build(:machine, license:, account:)

        expect(machine.policy_id).to eq license.policy_id
      end
    end

    context 'on create' do
      it 'should denormalize policy from unpersisted license' do
        policy  = build(:policy, account:)
        license = build(:license, policy:, account:)
        machine = create(:machine, license:, account:)

        expect(machine.policy_id).to eq policy.id
        expect(machine.policy).to eq policy
      end

      it 'should denormalize policy from persisted license' do
        license = create(:license, account:)
        machine = create(:machine, license:, account:)

        expect(machine.policy_id).to eq license.policy_id
      end
    end

    context 'on update' do
      it 'should denormalize policy from license' do
        license = create(:license, account:)
        machine = create(:machine, account:)

        machine.update!(license:)

        expect(machine.policy_id).to eq license.policy_id
      end
    end
  end

  describe '#owner=' do
    context 'on create' do
      it "should not raise when owner matches the license's owner" do
        license = create(:license, :with_owner, account:)
        owner   = license.owner
        machine = build(:machine, account:, license:, owner:)

        expect { machine.save! }.to_not raise_error
      end

      it "should not raise when owner matches one of the license's licensees" do
        license = create(:license, :with_licensees, account:)
        owner   = license.licensees.take
        machine = build(:machine, account:, license:, owner:)

        expect { machine.save! }.to_not raise_error
      end

      it "should not raise when owner is nil" do
        machine = build(:machine, account:, owner: nil)

        expect { machine.save! }.to_not raise_error
      end

      it "should raise when owner does not match one of the license's users" do
        license = create(:license, :with_users, account:)
        owner   = create(:user, account:)
        machine = build(:machine, account:, license:, owner:)

        expect { machine.save! }.to raise_error ActiveRecord::RecordInvalid
      end
    end

    context 'on update' do
      it "should not raise when owner matches the license's owner" do
        license = create(:license, :with_owner, account:)
        owner   = license.owner
        machine = create(:machine, account:, license:)

        expect { machine.update!(owner:) }.to_not raise_error
      end

      it "should not raise when owner matches one of the license's licensees" do
        license = create(:license, :with_licensees, account:)
        owner   = license.licensees.take
        machine = create(:machine, account:, license:)

        expect { machine.update!(owner:) }.to_not raise_error
      end

      it "should not raise when owner is nil" do
        machine = create(:machine, :with_owner, account:)

        expect { machine.update!(owner: nil) }.to_not raise_error
      end

      it "should raise when owner does not match one of the license's users" do
        license = create(:license, :with_users, account:)
        owner   = create(:user, account:)
        machine = create(:machine, account:, license:)

        expect { machine.update!(owner:) }.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end

  describe '#components_attributes=' do
    it 'should not raise when component is valid' do
      machine = build(:machine, account:, components_attributes: [
        attributes_for(:component, account:, environment: nil),
      ])

      expect { machine.save! }.to_not raise_error
    end

    it 'should raise when component is duplicated' do
      fingerprint = SecureRandom.hex
      machine     = build(:machine, account:, components_attributes: [
        attributes_for(:component, fingerprint:, account:, environment: nil),
        attributes_for(:component, fingerprint:, account:, environment: nil),
      ])

      expect { machine.save! }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'should raise when component is invalid' do
      machine = build(:machine, account:, components_attributes: [
        attributes_for(:component, fingerprint: nil, account:, environment: nil),
        attributes_for(:component, account:, environment: nil),
      ])

      expect { machine.save! }.to raise_error ActiveRecord::RecordInvalid
    end
  end

  describe '#components=' do
    it 'should not raise when component is valid' do
      machine = build(:machine, account:, components: build_list(:component, 3))

      expect { machine.save! }.to_not raise_error
    end

    it 'should raise when component is duplicated' do
      machine = build(:machine, account:, components: build_list(:component, 3, fingerprint: SecureRandom.hex))

      expect { machine.save! }.to raise_error ActiveRecord::RecordNotUnique
    end

    it 'should raise when component is invalid' do
      machine = build(:machine, account:, components: build_list(:component, 3, fingerprint: nil))

      expect { machine.save! }.to raise_error ActiveRecord::RecordInvalid
    end
  end

  describe '#status' do
    context 'when policy does not require heartbeats' do
      let(:policy)  { create(:policy, account:, require_heartbeat: false, heartbeat_duration: nil, heartbeat_resurrection_strategy: 'ALWAYS_REVIVE', heartbeat_cull_strategy: 'KEEP_DEAD', heartbeat_basis: 'FROM_FIRST_PING') }
      let(:license) { create(:license, policy:, account:) }

      it 'should provide status when idle' do
        machine = create(:machine, :idle, account:, license:)

        expect(machine.status).to eq 'NOT_STARTED'
      end

      it 'should provide status when idle but expired' do
        machine = create(:machine, :idle, account:, license:, created_at: 11.minutes.ago)

        expect(machine.status).to eq 'NOT_STARTED'
      end

      it 'should provide status when alive' do
        machine = create(:machine, :alive, account:, license:)

        expect(machine.status).to eq 'ALIVE'
      end

      it 'should provide status when dead' do
        machine = create(:machine, :dead, account:, license:)

        expect(machine.status).to eq 'DEAD'
      end

      it 'should provide status when resurrected' do
        machine = create(:machine, :dead, account:, license:)
        machine.resurrect!

        expect(machine.status).to eq 'RESURRECTED'
      end
    end

    context 'when policy does require heartbeats' do
      let(:policy)  { create(:policy, account:, require_heartbeat: true, heartbeat_duration: 10.minutes, heartbeat_resurrection_strategy: 'ALWAYS_REVIVE', heartbeat_cull_strategy: 'KEEP_DEAD', heartbeat_basis: 'FROM_FIRST_PING') }
      let(:license) { create(:license, policy:, account:) }

      it 'should provide status when idle' do
        machine = create(:machine, :idle, account:, license:)

        expect(machine.status).to eq 'NOT_STARTED'
      end

      it 'should provide status when idle but expired' do
        machine = create(:machine, :idle, account:, license:, created_at: 11.minutes.ago)

        expect(machine.status).to eq 'DEAD'
      end

      it 'should provide status when alive' do
        machine = create(:machine, :alive, account:, license:)

        expect(machine.status).to eq 'ALIVE'
      end

      it 'should provide status when dead' do
        machine = create(:machine, :dead, account:, license:)

        expect(machine.status).to eq 'DEAD'
      end

      it 'should provide status when resurrected' do
        machine = create(:machine, :dead, account:, license:)
        machine.resurrect!

        expect(machine.status).to eq 'RESURRECTED'
      end
    end
  end

  describe '.alive' do
    let(:no_heartbeat_policy) { create(:policy, account:, require_heartbeat: false, heartbeat_duration: nil) }
    let(:heartbeat_policy)    { create(:policy, account:, require_heartbeat: true,  heartbeat_duration: 10.minutes, heartbeat_basis: 'FROM_FIRST_PING') }
    let(:machines) {
      create_list(:machine, 5, :idle, account:, license: create(:license, policy: no_heartbeat_policy), created_at: 1.hour.ago)
      create_list(:machine, 5, :idle, account:, license: create(:license, policy: no_heartbeat_policy))
      create_list(:machine, 5, :alive, account:, license: build(:license, policy: no_heartbeat_policy))
      create_list(:machine, 5, :dead, account:, license: create(:license, policy: no_heartbeat_policy))
      create_list(:machine, 5, :idle, account:, license: build(:license, policy: heartbeat_policy), created_at: 1.hour.ago)
      create_list(:machine, 5, :idle, account:, license: build(:license, policy: heartbeat_policy))
      create_list(:machine, 5, :alive, account:, license: build(:license, policy: heartbeat_policy))
      create_list(:machine, 5, :dead, account:, license: create(:license, policy: heartbeat_policy))

      account.machines
    }

    it 'should return alive machines' do
      expect(machines.alive.count).to eq 25
    end
  end

  describe '.dead' do
    let(:no_heartbeat_policy) { create(:policy, account:, require_heartbeat: false, heartbeat_duration: nil) }
    let(:heartbeat_policy)    { create(:policy, account:, require_heartbeat: true,  heartbeat_duration: 10.minutes, heartbeat_basis: 'FROM_FIRST_PING') }
    let(:machines) {
      create_list(:machine, 5, :idle, account:, license: build(:license, policy: no_heartbeat_policy), created_at: 1.hour.ago)
      create_list(:machine, 5, :idle, account:, license: create(:license, policy: no_heartbeat_policy))
      create_list(:machine, 5, :alive, account:, license: create(:license, policy: no_heartbeat_policy))
      create_list(:machine, 5, :dead, account:, license: build(:license, policy: no_heartbeat_policy))
      create_list(:machine, 5, :idle, account:, license: build(:license, policy: heartbeat_policy), created_at: 1.hour.ago)
      create_list(:machine, 5, :idle, account:, license: create(:license, policy: heartbeat_policy))
      create_list(:machine, 5, :alive, account:, license: create(:license, policy: heartbeat_policy))
      create_list(:machine, 5, :dead, account:, license: build(:license, policy: heartbeat_policy))

      account.machines
    }

    it 'should return dead machines' do
      expect(machines.dead.count).to eq 15
    end
  end
end
