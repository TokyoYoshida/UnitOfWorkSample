require 'singleton'

# Mapperはサンプルなので何もしません
class SomeMapper 
    def self.insert(obj)
        puts "追加処理をしました"
    end

    def self.update(obj)
        puts "更新処理をしました"
    end

    def self.getSomeDomainObject()
        return SomeDomeinObject.create
    end
end

class UnitOfWork 
    include Singleton

    def initialize
        @newObjects = []
        @dirtyObjects = []
        @removedObjects = []
    end
    
    def registerNew(domainObj) 
        @newObjects << domainObj
    end

    def registerDirty(domainObj)
        @dirtyObjects << domainObj unless @dirtyObjects.include?(domainObj)
    end

    def registerRemoved(domainObj)
        return if @newObjects.delete domainObj
        @dirtyObjects.delete domainObj
        @removedObjects << domainObj unless @removedObjects.include?(domainObj)
    end

    def registerClean(domainObj)
    end

    def commit()
        insertNew()
        updateDirty()
        deleteRemoved()
    end

    def insertNew
        @newObjects.each do |o|
            SomeMapper.insert o
        end
    end

    def updateDirty
        @newObjects.each do |o|
            SomeMapper.update o
        end
    end

    def deleteRemoved
        # 略
    end
end

class DomainObject 
    def markNew
        UnitOfWork.instance.registerNew self
    end

    def markClean
        UnitOfWork.instance.registerClean self
    end

    def markDirty
        UnitOfWork.instance.registerDirty self
    end

    def markRemoved
        UnitOfWork.instance.registerRemoved self
    end
end

class SomeDomeinObject < DomainObject
    def self.create
        obj = SomeDomeinObject.new
        obj.markNew
        return obj
    end

    def setSomeValue(newValue)
        @some_value = newValue
        markDirty()
    end
end

dobj = SomeMapper.getSomeDomainObject()
dobj.setSomeValue("test")
UnitOfWork.instance.commit()
