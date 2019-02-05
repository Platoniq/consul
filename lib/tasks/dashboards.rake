namespace :dashboards do

  desc "Send to user notifications from new actions availability on dashboard"
  task send_notifications: :environment do
    Proposal.not_archived.each do |proposal|
      new_actions = Dashboard::Action.detect_new_actions(proposal)

      if new_actions.present?
        Dashboard::Mailer.new_actions_notification(proposal, new_actions).deliver_later
      end
    end
  end

end
