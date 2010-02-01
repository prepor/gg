class VariantsController < InheritedResources::Base
  belongs_to :package
  actions :show, :new, :create
  
  before_filter :only_maintainers, :only => [:approve, :decline]
  
  def approve
    resource.approve!
  end
  
  def decline
    resource.decline!
  end

  protected
  def build_resource
    super
    if action_name == 'new'
      @variant.add_default_depends
      @variant.set_hooks_for_new
    elsif action_name == 'create'
      @variant.created_by = current_user
    end
    @variant
  end
  
  def only_maintainers
    deny_access unless @variant.maintainers.include?(current_user)
  end
  
end

