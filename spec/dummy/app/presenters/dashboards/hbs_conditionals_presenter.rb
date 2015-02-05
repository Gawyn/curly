class Dashboards::HbsConditionalsPresenter < Curly::Presenter
  presents :name

  def bar?
    true
  end

  def nobar?
    false
  end

  def ifmethod
    "foo 3"
  end

  def methodif
    "foo 4"
  end

  def elsemethod
    "foo 5"
  end

  def methodelse
    "foo 6"
  end
end
