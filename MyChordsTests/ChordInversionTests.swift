//
//  ChordInversionTests.swift
//  MyChordsTests
//
//  Created by Assistant on 12/14/24.
//

import Testing
@testable import MyChords

struct ChordInversionTests {
    
    // MARK: - Helper Methods
    
    private func createTestChord() -> Chord {
        let notes = [
            Note(name: "C", octave: 4),
            Note(name: "E", octave: 4),
            Note(name: "G", octave: 4)
        ]
        return Chord(name: "C Major", symbol: "C", notes: notes)
    }
    
    private func createTestSeventhChord() -> Chord {
        let notes = [
            Note(name: "C", octave: 4),
            Note(name: "E", octave: 4),
            Note(name: "G", octave: 4),
            Note(name: "B", octave: 4)
        ]
        return Chord(name: "C Major 7", symbol: "Cmaj7", notes: notes)
    }
    
    // MARK: - Basic Inversion Tests
    
    @Test("Root position returns unchanged chord")
    func testRootPosition() throws {
        let chord = createTestChord()
        let inverted = chord.inverted(inversion: 0)
        
        #expect(inverted.notes.count == 3)
        #expect(inverted.notes[0].name == "C")
        #expect(inverted.notes[0].octave == 4)
        #expect(inverted.notes[1].name == "E")
        #expect(inverted.notes[1].octave == 4)
        #expect(inverted.notes[2].name == "G")
        #expect(inverted.notes[2].octave == 4)
        #expect(inverted.inversion == 0)
    }
    
    @Test("First inversion moves root note up an octave")
    func testFirstInversion() throws {
        let chord = createTestChord()
        let inverted = chord.inverted(inversion: 1)
        
        #expect(inverted.notes.count == 3)
        #expect(inverted.notes[0].name == "E")
        #expect(inverted.notes[0].octave == 4)
        #expect(inverted.notes[1].name == "G")
        #expect(inverted.notes[1].octave == 4)
        #expect(inverted.notes[2].name == "C")
        #expect(inverted.notes[2].octave == 5)
        #expect(inverted.inversion == 1)
        #expect(inverted.name == "C Major (1st Inversion)")
    }
    
    @Test("Second inversion moves two notes up an octave")
    func testSecondInversion() throws {
        let chord = createTestChord()
        let inverted = chord.inverted(inversion: 2)
        
        #expect(inverted.notes.count == 3)
        #expect(inverted.notes[0].name == "G")
        #expect(inverted.notes[0].octave == 4)
        #expect(inverted.notes[1].name == "C")
        #expect(inverted.notes[1].octave == 5)
        #expect(inverted.notes[2].name == "E")
        #expect(inverted.notes[2].octave == 5)
        #expect(inverted.inversion == 2)
        #expect(inverted.name == "C Major (2nd Inversion)")
    }
    
    // MARK: - Seventh Chord Inversions
    
    @Test("Seventh chord third inversion")
    func testSeventhChordThirdInversion() throws {
        let chord = createTestSeventhChord()
        let inverted = chord.inverted(inversion: 3)
        
        #expect(inverted.notes.count == 4)
        #expect(inverted.notes[0].name == "B")
        #expect(inverted.notes[0].octave == 4)
        #expect(inverted.notes[1].name == "C")
        #expect(inverted.notes[1].octave == 5)
        #expect(inverted.notes[2].name == "E")
        #expect(inverted.notes[2].octave == 5)
        #expect(inverted.notes[3].name == "G")
        #expect(inverted.notes[3].octave == 5)
        #expect(inverted.inversion == 3)
        #expect(inverted.name == "C Major 7 (3rd Inversion)")
    }
    
    // MARK: - Edge Cases
    
    @Test("Invalid inversion returns root position")
    func testInvalidInversion() throws {
        let chord = createTestChord()
        
        // Test negative inversion
        let negativeInversion = chord.inverted(inversion: -1)
        #expect(negativeInversion.inversion == 0)
        
        // Test inversion beyond chord size
        let tooHighInversion = chord.inverted(inversion: 3)
        #expect(tooHighInversion.inversion == 0)
        
        // Test very high inversion
        let veryHighInversion = chord.inverted(inversion: 10)
        #expect(veryHighInversion.inversion == 0)
    }
    
    // MARK: - Bass Note Tests
    
    @Test("Bass note changes correctly with inversions")
    func testBassNote() throws {
        let chord = createTestChord()
        
        // Root position
        #expect(chord.bassNote?.name == "C")
        
        // First inversion
        let firstInv = chord.inverted(inversion: 1)
        #expect(firstInv.bassNote?.name == "E")
        
        // Second inversion
        let secondInv = chord.inverted(inversion: 2)
        #expect(secondInv.bassNote?.name == "G")
    }
    
    // MARK: - Inversion Name Tests
    
    @Test("Inversion names are correct")
    func testInversionNames() throws {
        let chord = createTestChord()
        
        #expect(chord.inversionName == "Root Position")
        
        let inv1 = chord.inverted(inversion: 1)
        #expect(inv1.inversionName == "1st Inversion")
        
        let inv2 = chord.inverted(inversion: 2)
        #expect(inv2.inversionName == "2nd Inversion")
        
        let seventhChord = createTestSeventhChord()
        let inv3 = seventhChord.inverted(inversion: 3)
        #expect(inv3.inversionName == "3rd Inversion")
    }
    
    // MARK: - Complex Chord Tests
    
    @Test("Minor chord inversions")
    func testMinorChordInversions() throws {
        let notes = [
            Note(name: "A", octave: 4),
            Note(name: "C", octave: 5),
            Note(name: "E", octave: 5)
        ]
        let minorChord = Chord(name: "A Minor", symbol: "Am", notes: notes)
        
        let inverted = minorChord.inverted(inversion: 1)
        #expect(inverted.notes[0].name == "C")
        #expect(inverted.notes[0].octave == 5)
        #expect(inverted.notes[1].name == "E")
        #expect(inverted.notes[1].octave == 5)
        #expect(inverted.notes[2].name == "A")
        #expect(inverted.notes[2].octave == 5) // Already at octave 4, so goes to 5
    }
    
    // MARK: - Factory Method Tests
    
    @Test("Factory created chord inversions")
    func testFactoryChordInversions() throws {
        let chord = Chord.createMajorChord(root: "G", octave: 4)
        
        #expect(chord.notes[0].name == "G")
        #expect(chord.notes[1].name == "B")
        #expect(chord.notes[2].name == "D")
        
        let inverted = chord.inverted(inversion: 1)
        #expect(inverted.notes[0].name == "B")
        #expect(inverted.notes[0].octave == 4)
        #expect(inverted.notes[1].name == "D")
        #expect(inverted.notes[1].octave == 5)
        #expect(inverted.notes[2].name == "G")
        #expect(inverted.notes[2].octave == 5)
    }
}