{inputs}:
inputs.haumea.lib.load {
  src = ../secrets;
  loader = [
    (inputs.haumea.lib.matchers.extension "age" inputs.haumea.lib.loaders.path)
  ];
}
