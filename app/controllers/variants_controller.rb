class VariantsController < InheritedResources::Base
  belongs_to :package
  actions :show, :new, :create
  
  
  
  # def create
  #   @variant = build_resource_without_defaults
  # 
  #   @variant.package = @package
  #   
  #   if create_resource(@variant)
  #     options[:location] ||= resource_url rescue nil
  #   end
  # 
  #   respond_with_dual_blocks(@variant, options, &block)
  # end
  
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
  
  # def begin_of_association_chain
  #   @current_user
  # end

  
end

