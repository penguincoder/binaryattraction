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
