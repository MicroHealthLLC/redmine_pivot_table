module PivottablesHelper
  def pv_caption(colname)
    if @query
      col = @query.available_columns.find(){ |x| x.name == colname }
      if col
        col.caption
      end
    end
  end

  def parse_events(events)

    result_list = Array.new

    events.each{|e|

      if e.kind_of?(TimeEntry)
        hours = e.hours

      elsif e.kind_of?(Changeset)
        repository = e.repository

      end

      activity = l("label_#{e.event_type.split(' ').first.singularize.gsub(/-/, '_')}_plural")
      author = link_to_user(e.event_author) if e.respond_to?(:event_author)
      title = link_to(format_activity_title(e.event_title), e.event_url)

      time = e.event_datetime
      zone = User.current.time_zone
      local = zone ? time.in_time_zone(zone) : (time.utc? ? time.localtime : time)

      result_list.push({l("field_activity") => activity,
                        ID:e.id, 
                        l("field_author") => author, 
                        l("field_title") => title,
                        l("field_created_on") => local,
                        l("field_created_on")+"(y)" => local.year,
                        l("field_created_on")+"(m)" => local.month,
                        l("field_created_on")+"(d)" => local.mday,
                        l("field_created_on")+"(U)" => local.strftime("%U"),
                        l("field_created_on")+"(w)" => local.wday,
                        l("field_created_on")+"(h)" => local.hour,
                        })

    }
    result_list
  end

  def render_pivot_sidebar_queries
    out = ''.html_safe
    out << query_links(l(:label_my_queries), sidebar_queries.select(&:is_private?))
    out << query_links(l(:label_query_plural), sidebar_queries.reject(&:is_private?))
    out
  end

  def query_links(title, queries)
    return '' if queries.empty?
    # links to #index on issues/show
    url_params = controller_name == 'pivottables' ? {:controller => 'pivottables', :action => 'index', :project_id => @project} : params

    content_tag('h3', title) + "\n" +
        content_tag('ul',
                    queries.collect {|query|
                      css = 'query'
                      css << ' selected' if query == @query
                      content_tag('li', link_to(query.name, url_params.merge(:query_id => query), :class => css))
                    }.join("\n").html_safe,
                    :class => 'queries'
        ) + "\n"
  end

  def sidebar_queries
    unless @sidebar_pivot_queries
      @sidebar_pivot_queries = IssueQuery.visible.
          order("#{Query.table_name}.name ASC").
          # Project specific queries and global queries
          where(@project.nil? ? ["project_id IS NULL"] : ["project_id IS NULL OR project_id = ?", @project.id]).
          to_a
    end
    @sidebar_pivot_queries
  end
end
