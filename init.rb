require 'redmine'
require 'query_column_patch'

Rails.configuration.to_prepare do
  if Redmine::VERSION.to_s < "3.6.0"
    Rails.logger.info "redmine_pivot_table: patching QueryColumn for Redmine <2.6.0"
    require_dependency 'query'
    QueryColumn.send(:include, RedminePivotTable::QueryColumnPatch)
  end
end



Redmine::Plugin.register :redmine_pivot_table do
  name 'Redmine Pivot Table plugin'
  author 'Daiju Kito'
  description 'Pivot table plugin for Redmine using pivottable.js'
  version '0.0.4'
  url 'https://github.com/deecay/redmine_pivot_table'

  project_module :pivottables do
    permission :pivottables, {:pivottables => [:index]}, :public => true
  end

  menu :project_menu, :pivottables, { :controller => 'pivottables', :action => 'index' }, :after => :activity, :param => :project_id

end
