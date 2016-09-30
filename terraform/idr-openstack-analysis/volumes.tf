resource "openstack_blockstorage_volume_v2" "database_volume" {
  name = "${var.idr_environment}-database-db"
  size = 100
  # TODO: Snapshot or source_vol
  #snapshot_id =
  source_vol_id = "${var.database_db_volume_source}"
}

resource "openstack_blockstorage_volume_v2" "omero_volume" {
  name = "${var.idr_environment}-omero-data"
  size = 500
  # TODO: Snapshot or source_vol
  #snapshot_id =
  source_vol_id = "${var.omero_data_volume_source}"
}


resource "openstack_blockstorage_volume_v2" "jupyter_volume" {
  name = "${var.idr_environment}-docker-jupyter"
  size = 1
  # TODO: Snapshot or source_vol
  #snapshot_id =
  #source_vol_id =
}
