
class DB_Batch < ActiveRecord::Base
  def initialize
    @white_list=[]
    @black_list=[]
  end
  def add(db_batch)
    white_list db_batch.white_list
    black_list db_batch.black_list
  end

  def empty?
    if @white_list.count > 0 || @white_list.count > 0
      false
    else
      true
    end
  end
  def white_list(addrObj=nil)
    unless addrObj.is_a? NilClass
      @white_list.push(addrObj)
      @white_list.flatten!
    else
      @white_list
    end
  end

  def black_list(addrObj=nil)
    unless addrObj.is_a? NilClass
      @black_list.push(addrObj)
      @black_list.flatten!
    else
      @black_list
    end
  end

  def commit_white_list
    @white_list.each {|x| x.save}
    # white_list.clear
  end

  def commit_black_list
    @black_list.each {x.delete_all} #is it bad to do this here? should only be one record (theyre unique)
    # black_list.clear
  end
end
