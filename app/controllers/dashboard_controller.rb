class DashboardController < Dashboard::BaseController
  helper_method :dashboard_action, :active_resources, :course
  before_action :set_done_and_pending_actions, only: [:recommended_actions, :progress]

  def show
    authorize! :dashboard, proposal
  end

  def publish
    authorize! :publish, proposal

    proposal.publish
    redirect_to proposal_dashboard_path(proposal), notice: t('proposals.notice.published')
  end

  def progress
    authorize! :dashboard, proposal
  end

  def community
    authorize! :dashboard, proposal
  end

  def recommended_actions
    authorize! :dashboard, proposal
  end

  private

  def active_resources
    @active_resources ||= Dashboard::Action.active.resources.order(required_supports: :asc, day_offset: :asc)
  end

  def course
    @course ||= Dashboard::Action.course_for(proposal)
  end

  def set_done_and_pending_actions
    @done_actions = proposed_actions.joins(:proposals).where("proposals.id = ?", proposal.id)
    @pending_actions = proposed_actions - @done_actions
  end
end
