require "rails_helper"
require "rake"

describe "Dashboards Rake" do

  describe "#send_notifications" do

    before do
      Rake.application.rake_require "tasks/dashboards"
      Rake::Task.define_task(:environment)
      ActionMailer::Base.deliveries.clear
    end

    let :run_rake_task do
      Rake::Task["dashboards:send_notifications"].reenable
      Rake.application.invoke_task "dashboards:send_notifications"
    end

    describe "Not send notifications to proposal author when there are not news actions actived" do

      let!(:action)   { create(:dashboard_action, :proposed_action, :active, day_offset: 1) }
      let!(:resource) { create(:dashboard_action, :resource, :active, day_offset: 1) }

      it "for published proposals" do
        create(:proposal)

        run_rake_task

        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end

      it "for draft proposals" do
        create(:proposal, :draft)
        action.update(published_proposal: false)
        resource.update(published_proposal: false)

        run_rake_task

        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end

    end

    describe "Send notifications to proposal author when there are news actions actived" do

      context "for published proposals" do

        let!(:proposal) { create(:proposal) }
        let!(:action)   { create(:dashboard_action, :proposed_action, :active, day_offset: 0) }
        let!(:resource) { create(:dashboard_action, :resource, :active, day_offset: 0) }

        it "when proposal has been created today and day_offset is valid only for today" do
          run_rake_task

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end

        it "when proposal has been created some days ago and day_offset is valid only for today" do
          proposal.update(created_at: Date.today - 5.days, published_at: Date.today - 5.days)
          action.update(day_offset: 5)
          resource.update(day_offset: 5)

          run_rake_task

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end

        it "when proposal has received a new vote today" do
          proposal.update(created_at: Date.yesterday, published_at: Date.yesterday)
          action.update(required_supports: 1)
          resource.update(required_supports: 1)
          create(:vote, voter: proposal.author, votable: proposal)

          run_rake_task

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end

      end

      context "for draft proposals" do

        let!(:proposal) { create(:proposal, :draft) }
        let!(:action)   { create(:dashboard_action, :proposed_action, :active, day_offset: 0, published_proposal: false) }
        let!(:resource) { create(:dashboard_action, :resource, :active, day_offset: 0, published_proposal: false) }

        it "when day_offset field is valid for today and invalid for yesterday" do
          run_rake_task

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end

        it "when proposal has received a new vote today" do
          proposal.update(created_at: Date.yesterday)
          action.update(required_supports: 1)
          resource.update(required_supports: 1)
          create(:vote, voter: proposal.author, votable: proposal)

          run_rake_task

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end

      end
    end

  end

end
