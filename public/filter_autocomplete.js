// Autocomplete filter bar for the /activity page.
// Allows filtering by users and clans with include/exclude mode.
$(function() {
  var $input = $('#filter-autocomplete');
  var $suggestions = $('#filter-suggestions');
  // Debounce timer for autocomplete requests
  var timer;
  // Index of the keyboard-highlighted suggestion (-1 = none)
  var selectedIndex = -1;
  // Last loaded autocomplete results (used for existence validation)
  var suggestionData = [];

  function getFilterMode() {
    return $('input[name="filter_mode"]:checked').val() || 'include';
  }

  function getCurrentFilters() {
    var params = new URLSearchParams(window.location.search);
    return {
      users: (params.get('users') || '').split(',').filter(Boolean),
      clans: (params.get('clans') || '').split(',').filter(Boolean),
      mode: params.get('mode') || 'include'
    };
  }

  function buildUrl(filters) {
    var params = [];
    if (filters.users.length) params.push('users=' + filters.users.join(','));
    if (filters.clans.length) params.push('clans=' + filters.clans.join(','));
    if (filters.users.length || filters.clans.length) {
      params.push('mode=' + filters.mode);
    }
    return '/activity' + (params.length ? '?' + params.join('&') : '');
  }

  function switchMode() {
    var filters = getCurrentFilters();
    filters.mode = (filters.mode === 'include') ? 'exclude' : 'include';
    window.location.href = buildUrl(filters);
  }

  function addFilter(name, type) {
    if (!type) {
      // if name is not an existing db entry, return
      var match = suggestionData.find(function(item) {
        return item.name.toLowerCase() === name.toLowerCase();
      });
      if (!match) return;
      type = match.type;
    }
    var filters = getCurrentFilters();
    var key = type + 's';

    var idx = filters[key].indexOf(name);
    if (idx === -1) {
      filters[key].push(name);
    }
    filters.mode = getFilterMode();

    window.location.href = buildUrl(filters);
  }

  function updateHighlight() {
    $suggestions.find('.dropdown-item').removeClass('active');
    if (selectedIndex >= 0) {
      $suggestions.find('.dropdown-item').eq(selectedIndex).addClass('active');
    }
  }

  function showSuggestions(data) {
    $suggestions.empty().removeClass('show').hide();
    suggestionData = data || [];
    selectedIndex = -1;
    if (!data || !data.length) return;

    data.forEach(function(item, index) {
      var $item = $('<a class="dropdown-item" href="#">' +
        '<i class="fa-solid ' + (item.type === 'user' ? 'fa-user' : 'fa-users') + ' me-2"></i>' +
        item.name + '</a>');
      $item.on('click', function(e) {
        e.preventDefault();
        addFilter(item.name, item.type);
      });
      $suggestions.append($item);
    });

    $suggestions.addClass('show').show();
    // Auto-select the first entry
    selectedIndex = 0;
    updateHighlight();
  }

  // Input event: debounced autocomplete query from the first character onward
  $input.on('input', function() {
    clearTimeout(timer);
    var q = $.trim($input.val());
    if (q.length < 1) {
      $suggestions.removeClass('show').hide();
      return;
    }
    timer = setTimeout(function() {
      $.getJSON('/autocomplete', { q: q }, function(data) {
        showSuggestions(data);
      });
    }, 200);
  });

  $input.on('keydown', function(e) {
    var $items = $suggestions.find('.dropdown-item');

    if (e.key === 'ArrowDown') {
      e.preventDefault();
      if (!$suggestions.is(':visible')) return;
      selectedIndex = (selectedIndex + 1) % $items.length;
      updateHighlight();
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      if (!$suggestions.is(':visible')) return;
      selectedIndex = (selectedIndex - 1 + $items.length) % $items.length;
      updateHighlight();
    } else if (e.key === 'Enter') {
      e.preventDefault();
      if ($suggestions.is(':visible') && selectedIndex >= 0) {
        // Pick the keyboard-selected suggestion
        var item = suggestionData[selectedIndex];
        if (item) addFilter(item.name, item.type);
      } else {
        // Free-text input (validated against autocomplete data in addFilter)
        var q = $.trim($input.val());
        if (q.length >= 1) {
          addFilter(q);
        }
      }
    } else if (e.key === 'Escape') {
      $suggestions.removeClass('show').hide();
      selectedIndex = -1;
    }
  });

  $('input[name="filter_mode"]').on('change', function() {
    switchMode();
  });

  // Clicking outside closes the suggestion list
  $(document).on('click', function(e) {
    if (!$(e.target).closest('#filter-suggestions, #filter-autocomplete').length) {
      $suggestions.removeClass('show').hide();
      selectedIndex = -1;
    }
  });
});