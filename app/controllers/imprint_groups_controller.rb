class ImprintGroupsController < InheritedResources::Base
  belongs_to :order, optional: true
end
