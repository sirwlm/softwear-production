class TestTrain
  include ActiveModel::Model
  include ActiveModel::Serialization
  include ActiveRecord::Callbacks
  include Sunspot::Rails::Searchable
  include Train

  cattr_accessor :column_names
  def self.attr_accessor(*args)
    self.column_names ||= []
    self.column_names += args.map(&:to_s)
    super
  end

  define_callbacks :save

  attr_accessor :state
  attr_accessor :winner_id
  attr_accessor :other_field

  train_type :preproduction

  train :state, initial: :first, final: :success do
    event :normal_success do
      transition :first => :success
    end
    event :normal_failure do
      transition all => :failure
    end

    success_event :won, params: { winner_id: [1, 2, 3] }, public_activity: { user_id: [2, 4, 5] } do
      transition :first => :success
    end
    success_event :now_were_here, public_activity: { message: :text_field } do
      transition :failure => :success
    end
    failure_event :messed_up do
      transition :first => :failure
    end

    event :approve, public_activity: { user_id: [1, 2, 3] } do
      transition :first => :approved
    end
    failure_event :unsucceed, params: { reason: :text_field } do
      transition :success => :first
    end
    event :broadcast, public_activity: { message: :text_field } do
      transition :first => :success
    end

    state :failure, type: :bad
  end

  def update_attributes!(attrs)
    attrs.each { |key, value| send("#{key}=", value) }
    save!
  end
  def update_attributes(attrs)
    attrs.each { |key, value| send("#{key}=", value) }
    save
  end

  def id
    1
  end

  def attributes
    a = {}
    self.class.column_names.each do |col|
      a[col.to_s] = nil
    end
    a['id'] = nil
    a
  end

  def self.reflect_on_all_associations
    []
  end
end
