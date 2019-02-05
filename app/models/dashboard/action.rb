class Dashboard::Action < ActiveRecord::Base
  include Documentable
  documentable max_documents_allowed: 3,
               max_file_size: 3.megabytes,
               accepted_content_types: [ 'application/pdf', 'image/jpeg', 'image/jpg', 'image/png', 'application/zip' ]

  include Linkable

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  has_many :executed_actions, dependent: :restrict_with_error, class_name: 'Dashboard::ExecutedAction'
  has_many :proposals, through: :executed_actions

  enum action_type: [:proposed_action, :resource]

  validates :title,
            presence: true,
            allow_blank: false,
            length: { in: 4..80 }

  validates :action_type, presence: true

  validates :day_offset,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0
            }

  validates :required_supports,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0
            }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :resources, -> { where(action_type: 1) }
  scope :proposed_actions, -> { where(action_type: 0) }
  scope :by_draft, lambda { |draft_proposal|
    return where(published_proposal: false) if draft_proposal
  }
  scope :by_published_proposal, lambda { |published|
    return where(published_proposal: published)
  }

  def self.active_for(proposal)
    published_at = proposal.published_at&.to_date || Date.today

    active
      .where('required_supports <= ?', proposal.cached_votes_up)
      .where('day_offset <= ?', (Date.today - published_at).to_i)
      .by_draft(proposal.draft?)
  end

  def self.course_for(proposal)
    active
      .resources
      .where('required_supports > ?', proposal.cached_votes_up)
      .order(required_supports: :asc)
  end

  def active_for?(proposal)
    published_at = proposal.published_at&.to_date || Date.today

    required_supports <= proposal.cached_votes_up && day_offset <= (Date.today - published_at).to_i
  end

  def requested_for?(proposal)
    executed_action = executed_actions.find_by(proposal: proposal)
    return false if executed_action.nil?

    executed_action.administrator_tasks.any?
  end

  def executed_for?(proposal)
    executed_action = executed_actions.find_by(proposal: proposal)
    return false if executed_action.nil?

    executed_action.administrator_tasks.where.not(executed_at: nil).any?
  end

  def self.next_goal_for(proposal)
    course_for(proposal).first
  end

  def self.detect_new_actions(proposal)
    actions_for_today = get_actions_for_today(proposal)
    actions_for_yesterday = get_actions_for_yesterday(proposal)

    new_actions = actions_for_today - actions_for_yesterday
  end

  private
    def self.get_actions_for_today(proposal)
      proposal_votes = proposal.cached_votes_up
      day_offset = calculate_day_offset(proposal, Date.today)

      calculate_actions(proposal_votes, day_offset, proposal)
    end

    def self.get_actions_for_yesterday(proposal)
      proposal_votes = calculate_votes(proposal)
      day_offset = calculate_day_offset(proposal, Date.yesterday)

      calculate_actions(proposal_votes, day_offset, proposal)
    end

    def self.calculate_day_offset(proposal, date)
      start_date = proposal.published? ? proposal.published_at : proposal.created_at
      (date - start_date.to_date).to_i
    end

    def self.calculate_actions(proposal_votes, day_offset, proposal)
      Dashboard::Action.active.where("required_supports <= ?", proposal_votes)
                              .where("day_offset <= ?", day_offset)
                              .by_published_proposal(proposal.published?)
    end

    def self.calculate_votes(proposal)
      Vote.where(votable: proposal).where("created_at <= ?", Date.yesterday).count
    end
end
