module ComparisonsHelper

  def label_class( result )

    case result
      when Differ::Result::EQUAL then 'label-success'
      when Differ::Result::DIFFERENT then 'label-danger'
      when Differ::Result::INVALID then 'label-default'
    end

  end

  def result_name( result )

    case result
      when Differ::Result::EQUAL then 'Success'
      when Differ::Result::DIFFERENT then 'Danger'
      when Differ::Result::INVALID then 'Unknow'
    end

  end


end
