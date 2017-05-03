# GeocodeHelper
GeocodeHelper helps to make suggests on location and places for user's input based on Apple MapKit API

Features:
1. Delayed requests - search request is performed only when user stop writing
2. Inner cache

Usage:
GeocodeHelper.shared.decode(term, completion: { [weak self](places) -> () in
            //It may look smth like code below
            self?.dataSource.locations = places
            self?.tableView.reloadData()
            return
        })
