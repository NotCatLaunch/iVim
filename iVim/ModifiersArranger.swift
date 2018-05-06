//
//  ModifiersArranger.swift
//  iVim
//
//  Created by Terry Chou on 2018/5/6.
//  Copyright © 2018 Boogaloo. All rights reserved.
//

import Foundation

final class EKModifiersArranger {
    private var table = [KeyInfoID: EKModifierInfo]()
    private let queue = DispatchQueue.global()
}

extension EKModifiersArranger {
    func update(for button: OptionalButton, with keyString: String) {
        self.queue.sync(flags: .barrier) {
            if button.isOn { // register key info
                if !button.isHeld { // just turned on
                    guard let eki = button.effectiveInfo else { return }
                    let mi = EKModifierInfo(string: keyString, button: button)
                    self.table[eki.identifier] = mi
                    // clear other keys on this button
                    for oki in button.info.values where oki.identifier != eki.identifier {
                        self.table[oki.identifier] = nil
                    }
                }
            } else { // unregister key info
                guard let eki = button.effectiveInfo else { return }
                self.table[eki.identifier] = nil
            }
        }
    }
    
    func activeKeyStringSet(task: ((EKModifierInfo) -> Void)? = nil) -> Set<String> {
        var result = Set<String>()
        self.queue.sync {
            for mi in self.table.values {
                result.insert(mi.string)
                task?(mi)
            }
        }
        
        return result
    }
    
    func clear() {
        self.queue.sync(flags: .barrier) {
            self.table.removeAll()
        }
    }
}

struct EKModifierInfo {
    let string: String
    weak var button: OptionalButton?
}