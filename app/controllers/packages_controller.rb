class PackagesController < InheritedResources::Base
  actions :index, :show
  
  protected
     def collection
       @packages ||= end_of_association_chain.paginate(:page => params[:page])
     end  
end