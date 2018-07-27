// main idea: https://stepik.org/lesson/67655/step/1?after_pass_reset=true&unit=44395
// handle error: https://gist.github.com/pixelspark/e5836624303083ea2f04d59c25a468dd
// docs: http://pubs.opengroup.org/onlinepubs/7908799/xsh/pthread_rwlock_init.html

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true


class RWLock {
    
    private var lock = pthread_rwlock_t()
    
    init() {
        initResultHandler(pthread_rwlock_init(&lock, nil))
    }
    
    private var _property:Int?
    var property:Int? {
        get {
            lockResultHandler(pthread_rwlock_rdlock(&lock))
            
            sleep(2)
            
            let tmp = _property
            pthread_rwlock_unlock(&lock)
            return tmp
        }
        set {
            lockResultHandler(pthread_rwlock_wrlock(&lock))
            
            sleep(2)
            
            _property = newValue
            pthread_rwlock_unlock(&lock)
        }
    }
    
    private func lockResultHandler(_ val:Int32) {
        switch val {
        case 0:
            // Success
            break
        case EDEADLK:
            fatalError("Could not lock mutex: a deadlock would have occurred")
        case EINVAL:
            fatalError("Could not lock mutex: the mutex is invalid")
        default:
            fatalError("Could not lock mutex: unspecified error \(val)")
        }
    }
    private func initResultHandler(_ val:Int32) {
        switch val {
        case 0:
            // Success
            break
        case EAGAIN:
            fatalError("Could not create mutex: EAGAIN (The system temporarily lacks the resources to create another mutex.)")
        case EINVAL:
            fatalError("Could not create mutex: invalid attributes")
        case ENOMEM:
            fatalError("Could not create mutex: no memory")
        default:
            fatalError("Could not create mutex, unspecified error \(val)")
        }
    }
}


let lockExample = RWLock()

let queue = DispatchQueue(label: "com.example.rwlock", qos:.default, attributes: .concurrent)

queue.async {
    print(Date(), "did read", lockExample.property ?? -1)
}
queue.async {
    lockExample.property = 1
    print(Date(), "did write 1")
}
sleep(1)
queue.async {
    print(Date(), "did read", lockExample.property ?? -1)
}
queue.async {
    print(Date(), "did read", lockExample.property ?? -1)
}
