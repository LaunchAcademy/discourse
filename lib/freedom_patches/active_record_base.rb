class ActiveRecord::Base

  # Execute SQL manually
  def self.exec_sql(*args)
    conn = ActiveRecord::Base.connection
    sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
    conn.execute(sql)
  end

  def self.exec_sql_row_count(*args)
    exec_sql(*args).cmd_tuples
  end

  # note: update_attributes still spins up a transaction this can cause contention
  # this method performs the raw update sidestepping AR
  def update_columns(hash)
    sql = "UPDATE #{ self.class.table_name } SET "

    sql << hash.map do |k,v|
      "#{k} = :#{k}"
    end.join(",")

    sql << " WHERE id = :id"

    exec_sql(sql, hash.merge(id: self.id))
  end

  def exec_sql(*args)
    ActiveRecord::Base.exec_sql(*args)
  end


  # Executes the given block +retries+ times (or forever, if explicitly given nil),
  # catching and retrying SQL Deadlock errors.
  #
  # Thanks to: http://stackoverflow.com/a/7427186/165668
  #
  def self.retry_lock_error(retries=5, &block)
    begin
      yield
    rescue ActiveRecord::StatementInvalid => e
      if e.message =~ /deadlock detected/ && (retries.nil? || retries > 0)
        retry_lock_error(retries ? retries - 1 : nil, &block)
      else
        raise e
      end
    end
  end

  # Support for psql. If we want to support multiple RDBMs in the future we can
  # split this.
  def exec_sql_row_count(*args)
    exec_sql(*args).cmd_tuples
  end

end
