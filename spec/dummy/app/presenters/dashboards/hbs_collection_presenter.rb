class Dashboards::HbsCollectionPresenter < Curly::Presenter
  presents :items, :name

  def items
    @items
  end

  def empty_objects
    []
  end
end
