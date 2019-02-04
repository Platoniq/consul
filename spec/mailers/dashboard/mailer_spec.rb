require 'rails_helper'

describe Dashboard::Mailer do

  describe "#new_actions_notification" do

    before do
      Rake.application.rake_require "tasks/dashboards"
      Rake::Task.define_task(:environment)
      ActionMailer::Base.deliveries.clear
    end

    let :run_rake_task do
      Rake::Task["dashboards:send_notifications"].reenable
      Rake.application.invoke_task "dashboards:send_notifications"
    end

    let!(:proposal) { create(:proposal) }
    let!(:action)   { create(:dashboard_action, :proposed_action, :active, day_offset: 0) }
    let!(:resource) { create(:dashboard_action, :resource, :active, day_offset: 0) }

    it "sends emails when detect new actions for proposal" do
      run_rake_task

      email = open_last_email

      expect(email).to deliver_from('CONSUL <noreply@consul.dev>')
      expect(email).to deliver_to(proposal.author)
      expect(email).to have_subject("Proposal dashboard: New recommended action enabled!")
      expect(email).to have_body_text(proposal.title)
      expect(email).to have_body_text("Hi!")
      expect(email).to have_body_text("There are new recommended actions in your proposal dashboard!")
      expect(email).to have_body_text("Access your dashboard")
      expect(email).to have_body_text("New recommended actions available:")
      expect(email).to have_body_text(action.title)
      expect(email).to have_body_text(resource.title)
    end
  end
end
