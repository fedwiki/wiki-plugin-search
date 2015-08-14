
expand = (text)->
  text
    .replace /&/g, '&amp;'
    .replace /</g, '&lt;'
    .replace />/g, '&gt;'
    .replace /\*(.+?)\*/g, '<i>$1</i>'

emit = ($item, item) ->
  $item.append """
    <div style="width:93%; background:#eee; padding:.8em; margin-bottom:5px; text-align: center;">
      <span">#{expand item.text}</span>
      <p class="caption">waiting</p>
    </div>
  """

  flag = (site) ->
    """
      <img src="http://#{site}/favicon.png" width=16 title="#{site}">
    """

  twins = (slug, sites) ->
    "#{slug.replace(/-/g, ' ')}<br>#{(flag site for site in sites).join(' ')}"

  report = (result) ->
    (twins slug, sites for slug, sites of result).join('<br>')

  success = (data) ->
    $item.find('p.caption').text("#{Object.keys(data.result).length} titles")
    $item.append report data.result

  request =
    find: 'words',
    match: 'and',
    query: item.text || 'dorkbot'

  url = "http://#{item.site||'search.fed.wiki.org:3030'}/match"

  $.post(url, request, success, 'json')
    .fail (e) -> $item.find('.caption').text("search failed #{e.responseText}")

bind = ($item, item) ->
  $item.dblclick -> wiki.textEditor $item, item

window.plugins.search = {emit, bind} if window?
module.exports = {expand} if module?

