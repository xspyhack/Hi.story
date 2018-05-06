//
//  Launcher.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 24/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Hikit
import RealmSwift

struct Launcher {
    
    static func hi() {
        guard let realm = try? Realm() else { return }
        
        bornAuthor(withRealm: realm)
        bornHiTeam(withRealm: realm)
    }
    
    static func setupGod(with realm: Realm) {
        let userID = UUID.uuid
        let nickname = "What's your name?"
        let user = User()
        user.id = userID
        user.nickname = nickname
        user.bio = "No introduction yet."
        try? realm.write {
            realm.add(user, update: true)
        }
        
        HiUserDefaults.userID.value = userID
        HiUserDefaults.nickname.value = nickname
        HiUserDefaults.bio.value = "No introduction yet."
        
        // default storybook
        let book = Storybook()
        book.name = Configuration.Defaults.storybookName
        book.creator = user
        
        try? realm.write {
            realm.add(book, update: true)
        }
    }
    
    static func defaultStorybook(of userID: String) -> Storybook? {
        guard let realm = try? Realm() else { return nil }
        let predicate = NSPredicate(format: "name = %@ AND creator.id = %@", Configuration.Defaults.storybookName, userID)
        return realm.objects(Storybook.self).filter(predicate).first
    }
    
    private static func bornHiTeam(withRealm realm: Realm) {
        
        let team = User()
        team.id = UUID.uuid
        team.username = "hi"
        team.nickname = "Hi Team"
        team.bio = "We craft *cool* things"
        if let image = UIImage.hi.hiTeamAvatar {
            let key = URL.hi.imageURL(withPath: "hiteam").absoluteString
            ImageCache.shared.store(image, forKey: key)
            team.avatarURLString = key
        }
        team.createdAt = Date.hi.date(with: "2015-08-20", format: "yyyy-MM-dd")!.timeIntervalSince1970
        
        func teamMatter(title: String, happenedAt: String, body: String, tag: Tag) -> Matter {
            
            let matter = Matter()
            matter.title = title
            matter.happenedAt = Date.hi.date(with: happenedAt, format: "yyyy-MM-dd")!.timeIntervalSince1970
            matter.creator = team
            matter.kind = MatterKind.past.rawValue
            matter.tag = tag.rawValue
            matter.location = princePlanet()
            matter.body = body
            
            return matter
        }
        
        // Mind
        let mind = teamMatter(title: "Mind", happenedAt: "2015-08-08", body: "In my mind", tag: Tag.random())
        
        // plan
        let plan = teamMatter(title: "Plan", happenedAt: "2015-08-20", body: "Plan to do something", tag: Tag.random())
        
        // project
        let project = teamMatter(title: "Project", happenedAt: "2015-09-20", body: "Start code", tag: Tag.random())
        
        // release
        let release = teamMatter(title: "Release", happenedAt: "2016-02-01", body: "Congratulations", tag: Tag.random())
        
        // Feed
        let story = Story()
        story.title = "Welcome to Hi.story"
        story.body = "Hi.story is a simple, flexible recording app for life and time. It's easy to get started and master Hi.story, so let's show you around.\n\n### Features\n\n#### Stories\n\n* Timeline: Displaying your stories in chronological order. All your stories live here.\n\n* Editor: This is where your magic happens. You can also use **Markdown** syntax to write your `story`.\n\n#### Matters\n\nYou can record some important matters with Hi.story. It helps you counting days when the matter *happened* or *will happen*. `+233` means that the matter will happen after 233 days. otherwise `-233` means that the matter happened 233 days ago.\n\n#### History\n\nCollecting your memories from *Photos* *Reminders* *Calendar* system build-in apps and *Stories* *Matters* you recorded with **Hi.story** to show you what were you doing a year ago today.\n\n### More\n\nYou can check the **Hi.story** website [official website](https://blessingsoft.com) to know more about **Hi.story**.\n\nWe would *love* to hear your feedback at [xspyhack@gmail.com](mailto:xspyhack@gmail.com)"
        
        story.location = princePlanet()
        story.isPublished = true
       
        // default storybook
        let book = Storybook()
        book.name = "Hi.story"
        book.creator = team
        
        story.withStorybook = book
        
        let feed = Feed()
        feed.story = story
        feed.creator = team
        
        realm.beginWrite()
        
        realm.add(team, update: true)
        realm.add(mind)
        realm.add(plan)
        realm.add(project)
        realm.add(release)
        realm.add(feed)
        
        try? realm.commitWrite()
    }
    
    private static func bornAuthor(withRealm realm: Realm) {
        let author = User()
        author.id = UUID.uuid
        author.nickname = "blessing software"
        author.username = Configuration.author
        author.bio = "megumi soft"
        if let image = UIImage.hi.authorAvatar {
            let key = URL.hi.imageURL(withPath: "author").absoluteString
            ImageCache.shared.store(image, forKey: key)
            author.avatarURLString = key
        }
        author.createdAt = Date.hi.date(with: "2333-3-13", format: "yyyy-MM-dd")!.timeIntervalSince1970
        
        let founded = Matter()
        founded.title = "Founded"
        founded.happenedAt = Date.hi.date(with: "2333-3-13", format: "yyyy-MM-dd")!.timeIntervalSince1970
        founded.location = princePlanet()
        founded.kind = MatterKind.coming.rawValue
        founded.creator = author
        founded.tag = Tag.hi.rawValue
        founded.body = "Founder: alex@blessingsoft.com"
        
        try? realm.write {
            realm.add(author, update: true)
            realm.add(founded)
        }
    }
    
    private static func princePlanet() -> Location {
        
        let location = Location()
        location.name = "b233 prince planet"
        let coordinate = Coordinate()
        coordinate.latitude = 0.0
        coordinate.longitude = 0.0
        location.coordinate = coordinate
        
        return location
    }
}
