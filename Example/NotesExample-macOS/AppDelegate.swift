//  Copyright © 2018 ObjectBox. All rights reserved.

import Cocoa
import ObjectBox

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var store: Store!
    lazy var authorBox: Box<Author> = self.store.box(for: Author.self)
    lazy var noteBox: Box<Note> = self.store.box(for: Note.self)

    lazy var logger: Logger = Logger()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        do {
            logger.append("Setting up store ...")
            self.store = try Store.createStoreInTemporaryDirectory()
            logger.append("Store path: \(store.directoryPath)")
            logger.appendSeparator()

            logger.append("Setting up authors ...")
            let peterBrett = Author(name: "Peter V. Brett")
            let georgeMartin = Author(name: "George R. R. Martin")
            try authorBox.put([peterBrett, georgeMartin])
            logger.append("\(peterBrett)")
            logger.append("\(georgeMartin)")
            logger.appendSeparator()

            logger.append("Writing notes ...")
            try noteBox.put(Note(title: "Unclaimed idea", text: "This writing is not by anyone in particular."))
            try noteBox.put(peterBrett.writeNote(title: "The Warded Man", text: "I should make a movie from this book after writing the next novel."))
            try noteBox.put(peterBrett.writeNote(title: "Daylight War", text: "Who picked the cover art for this? It certainly wasn't me or someone else with taste."))
            try noteBox.put(georgeMartin.writeNote(title: "Game of Thrones", text: "This book title would've been a better choice than this Ice & Fire stuff all along. Boy, writing this takes long in DOS."))

            logger.append("Reading all notes:")
            logger.append("\(noteBox.all().readableDescription)\n")

            logger.append("Reading notes containing 'writing':")
            let allWritingNotes = noteBox.query { Note.text.contains("writing") }.find()
            logger.append("\(allWritingNotes.readableDescription)\n")

            logger.append("Reading notes containing 'writing' by Peter Brett:")
            let peterBrettsWritingNotes = noteBox.query { Note.text.contains("writing") && Note.author == peterBrett.id }.find()
            logger.append("\(peterBrettsWritingNotes.readableDescription)\n")

            logger.append("Looking into Peter Brett's current object state again ...")
            logger.append("\(peterBrett)")
            logger.append("Note the lazy relation didn't update automatically once fetched.\nBut if we fetch a new instance by his id ...")
            logger.append("\(authorBox.get(peterBrett.id)?.description ?? "(fetch failed)")")
        } catch {
            logger.append("❌ ERROR: \(error)")
        }

        let viewController = NSApp.mainWindow?.contentViewController
        logger.display(viewController: viewController!)
        print(logger.string)
    }
}
