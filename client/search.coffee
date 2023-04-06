
expand = (text)->
  text
    .replace /&/g, '&amp;'
    .replace /</g, '&lt;'
    .replace />/g, '&gt;'
    .replace /\*(.+?)\*/g, '<i>$1</i>'

emit = ($item, item) ->

  flag = (slug, site) ->
    """
      <img class="remote"
        title="#{site}"
        src="http://#{site}/favicon.png"
        data-site="#{site}"
        data-slug="#{slug}">
    """

  twins = (slug, sites) ->
    "#{slug.replace(/-/g, ' ')}<br>#{(flag slug, site for site in sites).join(' ')}"

  report = (result) ->
    (twins slug, sites for slug, sites of result).join('<br>')

  $item.append if item.result?
    "<div class=report>#{report item.result}</div>"
  else
    """
      <div style="width:93%; background:#eee; padding:16px; margin-bottom:5px; text-align: center;">
        <span>#{expand item.text}<br></span>
        <p class="caption">ready</p>
        <div class=report style="text-align:left;"></div>
      </div>
    """

  status = (text) ->
    $item.find('p.caption').text text

  success = (data, elapsed) ->
    status "#{Object.keys(data.result).length} titles, #{elapsed} sec"
    $item
      .find('.report')
      .append report data.result

  search = (request) ->
    url = "http://#{item.site||'search.fed.wiki.org:3030'}/match"
    console.log 'search', request
    quickly = () ->
      start = Date.now()
      (data) ->
        stop = Date.now()
        success data, (stop-start)/1000.0
    $.post(url, request, quickly(), 'json')
      .fail (e) -> status "search failed: #{e.responseText || e.statusText}"
    $item.find('.report').empty()
    status "searching"

  keystroke = (e) ->
    if e.keyCode == 13
      input = $item.find('input').val()
      if input.match /\w/
        request = $.extend({}, $item.request);
        request.query += " #{input}"
        search request

  handle = (request) ->
    if request.input
      $item.request = request
      $item
        .find('span')
        .append '<input type=text style="width: 95%;"></input>'
        .on 'keyup', keystroke
    else if request.search
      $item.request = request
      $item
        .find('span')
        .append '<button>search</button>'
        .on 'click', () -> search request
    else
      search request

  parse = (text) ->
    request = {}
    text = text.replace /\b(AND|OR)\b/g, (op) ->
      request.match = op.toLowerCase()
      ''
    text = text.replace /\b(ALL)\b/, (op) ->
      request.match = 'and'
      ''
    text = text.replace /\b(ANY)\b/, (op) ->
      request.match = 'or'
      ''
    text = text.replace /\b(WORDS|LINKS|SITES|SLUGS|ITEMS|PLUGINS)\b/g, (op) ->
      request.find = op.toLowerCase()
      ''
    text = text.replace /\b(INPUT)\b/, (op) ->
      request.input = true
      ''
    text = text.replace /\b(SEARCH)\b/, (op) ->
      request.search = true
      ''
    request.query = text
    request

  handle parse item.text if item.text?

bind = ($item, item) ->
  $item.on 'dblclick', () -> wiki.textEditor $item, item
  $item.find('input').on 'dblclick', () -> false

window.plugins.search = {emit, bind} if window?
module.exports = {expand} if module?

