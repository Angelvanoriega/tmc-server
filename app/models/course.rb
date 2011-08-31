require 'gdocs_backend'

class Course < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include GitBackend

  self.include_root_in_json = false

  validates :name,
            :presence   => true,
            :uniqueness => true,
            :length     => { :within => 1..40 },
            :format     => {
              :without => / /,
              :message  => 'should not contain white spaces'
            }

  has_many :exercises, :dependent => :destroy
  has_many :submissions, :dependent => :destroy
  has_many :available_points, :through => :exercises
  has_many :awarded_points, :dependent => :destroy

  before_save lambda { self.remote_repo_url = nil if self.remote_repo_url.blank? }
  after_create :create_local_repository, :if => lambda { has_local_repo? }
  after_destroy :delete_local_repository, :if => lambda { has_local_repo? }

  scope :ongoing, lambda { where(["hide_after IS NULL OR hide_after > ?", Time.now]) }
  scope :expired, lambda { where(["hide_after IS NOT NULL AND hide_after <= ?", Time.now]) }

  def visible?
    !hidden && (hide_after == nil || hide_after > Time.now)
  end

  def has_remote_repo?
    !remote_repo_url.nil?
  end

  def has_local_repo?
    !has_remote_repo?
  end

  def bare_path
    super if has_local_repo?
  end

  def bare_url
    if has_local_repo?
      super
    else
      remote_repo_url
    end
  end

  def hide_after=(x)
    super(DateAndTimeUtils.to_time(x, :prefer_end_of_day => true))
  end

  def gdocs_sheets
    self.exercises.map(&:gdocs_sheet).uniq
  end

  def refresh_gdocs
    GDocsBackend.refresh_course_spreadsheet self
  end

  def refresh
    CourseRefresher.new.refresh_course(self)
  end

  def options=(new_options)
    if !new_options["hide_after"].blank?
      self.hide_after = new_options["hide_after"]
    else
      self.hide_after = nil
    end

    self.hidden = !!new_options['hidden']
  end

  def self.default_options
    {
      :hidden => false,
      :hide_after => nil
    }
  end
end

