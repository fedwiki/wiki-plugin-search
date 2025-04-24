const defaultSearchProvider = 'query.search.federatedwiki.org'

const expand = text => {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/\*(.+?)\*/g, '<i>$1</i>')
}

const emit = ($item, item) => {
  const flag = (slug, site) => {
    return `
      <img class="remote"
        title="${site}"
        src="http://${site}/favicon.png"
        data-site="${site}"
        data-slug="${slug}">`
  }

  const twins = (slug, sites) => {
    return `${slug.replace(/-/g, ' ')}<br>${sites.map(site => flag(slug, site)).join(' ')}`
  }

  const report = result => {
    return Object.entries(result)
      .map(([slug, sites]) => `${twins(slug, sites)}`)
      .join('<br>')
  }

  $item.append(
    !!item?.result
      ? `<div class="report">${report(item.result)}</div>`
      : `
      <div style="width:93%; background:#eee; padding:16px; margin-bottom:5px; text-align: center;">
        <span>${expand(item.text)}<br></span>
        <p class="caption">ready</p>
        <div class="report" style="text-align:left;"></div>
      </div>
    `,
  )

  const status = text => {
    $item.find('p.caption').text(text)
  }

  const success = (data, elapsed) => {
    status(`${Object.keys(data.result).length} titles, ${elapsed} sec`)
    $item.find('.report').append(report(data.result))
  }

  const search = request => {
    const url = `//${item.site || defaultSearchProvider}/match`
    console.log('search', request)
    const quickly = () => {
      const start = Date.now()
      return data => {
        const end = Date.now()
        success(data, (end - start) / 1000.0)
      }
    }
    $.post(url, request, quickly(), 'json').fail(e => status(`search failed: ${e.responseText || e.statusText}`))
    $item.find('.report').empty()
    status('searching')
  }

  const keystroke = e => {
    if (e.keyCode == 13) {
      const input = $item.find('input').val()
      if (input.match(/\w/)) {
        const request = { ...$item.request }
        request.query += `${input}`
        search(request)
      }
    }
  }

  const handle = request => {
    if (request.input) {
      $item.request = request
      $item.find('span').append('<input type=text style="width: 95%;"></input>').on('keyup', keystroke)
    } else if (request.search) {
      $item.request = request
      $item
        .find('span')
        .append('<button>search</button>')
        .on('click', () => search(request))
    } else {
      search(request)
    }
  }

  const parse = text => {
    const request = {}

    text = text.replace(/\b(AND|OR)\b/g, op => {
      request.match = op.toLowerCase()
      return ''
    })
    text = text.replace(/\b(ALL)\b/, () => {
      request.match = 'and'
      return ''
    })
    text = text.replace(/\b(ANY)\b/, () => {
      request.match = 'or'
      return ''
    })
    text = text.replace(/\b(WORDS|LINKS|SITES|SLUGS|ITEMS|PLUGINS)\b/g, op => {
      request.find = op.toLowerCase()
      return ''
    })
    text = text.replace(/\b(INPUT)\b/, () => {
      request.input = true
      return ''
    })
    text = text.replace(/\b(SEARCH)\b/, () => {
      request.search = true
      return ''
    })
    request.query = text.trim()
    return request
  }

  // only if item.text is present, and not all spaces
  if (!!item?.text && item.text.trim().length > 0) {
    handle(parse(item.text))
  }
}

const bind = ($item, item) => {
  $item.on('dblclick', () => wiki.textEditor($item, item))
  $item.find('input').on('dblclick', () => false)
}

if (typeof window !== 'undefined') {
  window.plugins.search = { emit, bind }
}

export const search = typeof window == 'undefined' ? { expand } : undefined
