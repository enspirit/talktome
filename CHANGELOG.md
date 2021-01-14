# 0.3.0 - 2021/03/26

* Update dependencies. Path version must be >= 2.0, which may
  force dependent projects to upgrade too.

* Add travis to check for multi build matrices.

# 0.2.0 - 2019/03/20

* Weaken non-critical dependencies (mustache, path, redcarpet) to avoid unnecessary
  integration issues.

* A strategy now yields the block passed at `Client#talktome` with the strategy
  concrete message asset. The Email strategy for instance yields a Mail instance.
  This provides a chance to fix a few details on sending.

* Clients can now be instantiated without options, default options will be
  infered from environment variables.

# 0.1.0 - A long time ago

Birthday
