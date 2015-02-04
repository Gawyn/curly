Rails.application.routes.draw do
  root to: "dashboards#show"
  get "/collection", to: "dashboards#collection"
  get "/partials", to: "dashboards#partials"
  get "/new", to: "dashboards#new"
  get "/new", to: "dashboards#new"
  get "/conditionals", to: "dashboards#conditionals"
  get "/hbs-conditionals", to: "dashboards#hbs_conditionals"
  get "/hbs-collection", to: "dashboards#hbs_collection"
end
