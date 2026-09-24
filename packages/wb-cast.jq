def target_text:
  if has("Window") then {"text": ("Window: " + (.Window.id | tostring))}
  elif has("Output") then {"text": ("Output: " + .Output.name)}
  elif has("Nothing") then {"text": "Nothing"}
  else {"text": ""}
  end;

if has("CastsChanged") then
  (.CastsChanged.casts | .[0]) as $cast |
  if $cast != null then $cast.target | target_text
  else {"text": ""}
  end
elif has("CastStopped") then
  {"text": ""}
elif has("CastStartedOrChanged") then
  .CastStartedOrChanged.cast.target | target_text
else empty
end
