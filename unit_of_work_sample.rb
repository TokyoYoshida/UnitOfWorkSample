require 'singleton'

# Mapperはサンプルなので何もしません
class SomeMapper 
    def self.insert(obj)
        puts "追加処理"
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
        inertNew()
        updateDirty()
        deleteRemoved()
    end

    def insertNew
        @newObjects.each do |o|
            SomeMapper.insert o
        end
    end

    def updateDirty
        # 略
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

u = UnitOfWork.instance


u.registerNew(1)
u.registerDirty(1)

p u

test = []
test << 1
r = test.delete(2)
p test 
p r