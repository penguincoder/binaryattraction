function addLoadEvent(func)
{
  var oldonload = window.onload;
  if (typeof window.onload != 'function')
  {
    window.onload = func;
  }
  else
  {
    window.onload = function()
    {
      oldonload();
      func();
    }
  }
}

function hide_flashes()
{
  addLoadEvent(function(){
    setTimeout('hide_flashes_timer()', 30000);
  });
}

function hide_flashes_timer()
{
  new Effect.DropOut($('flash_container'));
}

function vote(url)
{
  new Ajax.Updater(
    {success: 'main_photo_container', failure: 'vote_error'},
    url,
    {
      synchronous: true,
      onCreate: function()
      {
        if($('vote_error').style.display != 'none')
          new Effect.Fade($('vote_error'));
      },
      onFailure: function()
      {
        new Effect.Appear($('vote_error'));
      },
      onSuccess: function()
      {
        if($('vote_error').style.display != 'none')
          new Effect.Fade($('vote_error'));
      }
    }
  );
}
