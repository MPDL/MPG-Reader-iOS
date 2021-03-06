/*************************************************************************
 *
 * REALM CONFIDENTIAL
 * __________________
 *
 *  [2011] - [2015] Realm Inc
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Realm Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Realm Incorporated
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Realm Incorporated.
 *
 **************************************************************************/

#include <cstdint>
#include <memory>
#include <chrono>
#include <string>

#include <realm/util/string_view.hpp>
#include <realm/impl/cont_transact_hist.hpp>
#include <realm/sync/instruction_replication.hpp>
#include <realm/sync/protocol.hpp>
#include <realm/sync/transform.hpp>
#include <realm/sync/object_id.hpp>
#include <realm/sync/instructions.hpp>

#ifndef REALM_SYNC_HISTORY_HPP
#define REALM_SYNC_HISTORY_HPP


namespace realm {
namespace _impl {

struct ObjectIDHistoryState;

} // namespace _impl
} // namespace realm


namespace realm {
namespace sync {

struct VersionInfo {
    /// Realm snapshot version.
    version_type realm_version = 0;

    /// The synchronization version corresponding to `realm_version`.
    ///
    /// In the context of the client-side history type `sync_version.version`
    /// will currently always be equal to `realm_version` and
    /// `sync_version.salt` will always be zero.
    SaltedVersion sync_version = {0, 0};
};


struct SerialTransactSubstitutions {
    struct Class {
        InternString name;
        std::size_t substitutions_end;
    };
    std::vector<Class> classes;
    std::vector<std::pair<ObjectID, ObjectID>> substitutions;
};


class ClientHistoryBase :
        public InstructionReplication {
public:
    using SyncTransactCallback = void(VersionID old_version, VersionID new_version);

    /// Get the version of the latest snapshot of the associated Realm, as well
    /// as the client file identifier and the synchronization progress as they
    /// are stored in that snapshot.
    ///
    /// Note: The value of `progress.upload.last_integrated_server_version` may
    /// currently be wrong when the caller is the synchronization client
    /// (`_impl::ClientImplBase`), in the sense that the server version number
    /// may not actually be the version upon which the client version was based.
    /// On the client, it must therefore only be used in a limited capacity,
    /// namely to report download progress to the server. The number reflects a
    /// lower bound on the server version that any changeset produced by the
    /// client in the future can be based upon. The caller passes the returned
    /// value back to find_uploadable_changesets() or set_sync_progress(), so if
    /// the history implementation does not care about the value of
    /// `progress.upload.last_integrated_server_version`, it is allowed to not
    /// persist it. However, the implementation of find_uploadable_changesets()
    /// must still be prepared for its value to be determined by an incoming
    /// DOWNLOAD message, rather than being whatever was returned by
    /// get_status().
    ///
    /// The returned current client version is the version produced by the last
    /// changeset in the history. The type of version returned here, is the one
    /// that identifies an entry in the sync history. Whether this is the same
    /// as the snapshot number of the Realm file depends on the history
    /// implementation.
    ///
    /// The returned client file identifier is the one that was last stored by
    /// set_client_file_ident(), or `SaltedFileIdent{0, 0}` if
    /// set_client_file_ident() has never been called.
    ///
    /// The returned SyncProgress is the one that was last stored by
    /// set_sync_progress(), or `SyncProgress{}` if set_sync_progress() has
    /// never been called.
    virtual void get_status(version_type& current_client_version,
                            SaltedFileIdent& client_file_ident,
                            SyncProgress& progress) const = 0;

    /// Stores the server assigned client file identifier in the associated
    /// Realm file, such that it is available via get_status() during future
    /// synchronization sessions. It is an error to set this identifier more
    /// than once per Realm file.
    ///
    /// \param client_file_ident The server assigned client-side file
    /// identifier. A client-side file identifier is a non-zero positive integer
    /// strictly less than 2**64. The server guarantees that all client-side
    /// file identifiers generated on behalf of a particular server Realm are
    /// unique with respect to each other. The server is free to generate
    /// identical identifiers for two client files if they are associated with
    /// different server Realms.
    ///
    /// \param fix_up_object_ids The object ids that depend on client file ident
    /// will be fixed in both state and history if this parameter is true. If
    /// it is known that there are no objects to fix, it can be set to false to
    /// achieve higher performance.
    ///
    /// The client is required to obtain the file identifier before engaging in
    /// synchronization proper, and it must store the identifier and use it to
    /// reestablish the connection between the client file and the server file
    /// when engaging in future synchronization sessions.
    virtual void set_client_file_ident(SaltedFileIdent client_file_ident,
                                       bool fix_up_object_ids) = 0;

    /// Stores the SyncProgress progress in the associated Realm file in a way
    /// that makes it available via get_status() during future synchronization
    /// sessions. Progress is reported by the server in the DOWNLOAD message.
    ///
    /// See struct SyncProgress for a description of \param progress.
    ///
    /// Note: The implementation is not obligated to store the value of
    /// `progress.upload.last_integrated_server_version`, however, if the
    /// implementation chooses to not store it, then its value will be
    /// unreliable when passed to the implementation through functions such as
    /// find_uploadable_changesets(). It may, or may not be the value last
    /// returned for it by get_status().
    virtual void set_sync_progress(const SyncProgress& progress, VersionInfo&) = 0;

    struct UploadChangeset {
        timestamp_type origin_timestamp;
        file_ident_type origin_file_ident;
        UploadCursor progress;
        ChunkedBinaryData changeset;
        std::unique_ptr<char[]> buffer;
    };

    /// \brief Scan through the history for changesets to be uploaded.
    ///
    /// This function scans the history for changesets to be uploaded, i.e., for
    /// changesets that are not empty, and were not produced by integration of
    /// changesets recieved from the server. The scan begins at the position
    /// specified by the initial value of \a upload_progress.client_version, and
    /// ends no later than at the position specified by \a end_version.
    ///
    /// The implementation is allowed to end the scan before \a end_version,
    /// such as to limit the combined size of returned changesets. However, if
    /// the specified range contains any changesets that are supposed to be
    /// uploaded, this function must return at least one.
    ///
    /// Upon return, \a upload_progress will have been updated to point to the
    /// position from which the next scan should resume. This must be a position
    /// after the last returned changeset, and before any remaining changesets
    /// that are supposed to be uploaded, although never a position that
    /// succeeds \a end_version.
    ///
    /// The value passed as \a upload_progress by the caller, must either be one
    /// that was produced by an earlier invocation of
    /// find_uploadable_changesets(), one that was returned by get_status(), or
    /// one that was received by the client in a DOWNLOAD message from the
    /// server. When the value comes from a DOWNLOAD message, it is supposed to
    /// reflect a value of UploadChangeset::progress produced by an earlier
    /// invocation of find_uploadable_changesets().
    ///
    /// For changesets of local origin, UploadChangeset::origin_file_ident will
    /// be zero.
    virtual std::vector<UploadChangeset> find_uploadable_changesets(UploadCursor& upload_progress,
                                                                    version_type end_version) const = 0;

    using RemoteChangeset = Transformer::RemoteChangeset;

    // FIXME: Apparently, this feature is expected by object store, but why?
    // What is it ultimately used for? (@tgoyne)
    class SyncTransactReporter {
    public:
        virtual void report_sync_transact(VersionID old_version, VersionID new_version) = 0;
    protected:
        ~SyncTransactReporter() {}
    };

    enum class IntegrationError {
        bad_origin_file_ident,
        bad_changeset
    };

    /// \brief Integrate a sequence of changesets received from the server using
    /// a single Realm transaction.
    ///
    /// Each changeset will be transformed as if by a call to
    /// Transformer::transform_remote_changeset(), and then applied to the
    /// associated Realm.
    ///
    /// As a final step, each changeset will be added to the local history (list
    /// of applied changesets).
    ///
    /// This function checks whether the specified changesets specify valid
    /// remote origin file identifiers and whether the changesets contain valid
    /// sequences of instructions. The caller must already have ensured that the
    /// origin file identifiers are strictly positive and not equal to the file
    /// identifier assigned to this client by the server.
    ///
    /// If any of the changesets are invalid, this function returns false and
    /// sets `integration_error` to the appropriate value. If they are all
    /// deemed valid, this function updates \a version_info to reflect the new
    /// version produced by the transaction.
    ///
    /// \param progress is the SyncProgress received in the download message.
    /// Progress will be persisted along with the changesets.
    ///
    /// \param num_changesets The number of passed changesets. Must be non-zero.
    ///
    /// \param transact_reporter An optional callback which will be called with the
    /// version immediately processing the sync transaction and that of the sync
    /// transaction.
    virtual bool integrate_server_changesets(const SyncProgress& progress,
                                             const RemoteChangeset* changesets,
                                             std::size_t num_changesets, VersionInfo& new_version,
                                             IntegrationError& integration_error, util::Logger&,
                                             SyncTransactReporter* transact_reporter = nullptr,
                                             const SerialTransactSubstitutions* = nullptr) = 0;

protected:
    ClientHistoryBase(const std::string& realm_path);

    static timestamp_type generate_changeset_timestamp() noexcept;
};



class ClientHistory : public ClientHistoryBase {
public:
    class ChangesetCooker;
    class Config;

    /// Get the persisted upload/download progress in bytes.
    virtual void get_upload_download_bytes(std::uint_fast64_t& downloaded_bytes,
                                           std::uint_fast64_t& downloadable_bytes,
                                           std::uint_fast64_t& uploaded_bytes,
                                           std::uint_fast64_t& uploadable_bytes,
                                           std::uint_fast64_t& snapshot_version) = 0;

    /// See set_cooked_progress().
    struct CookedProgress {
        std::int_fast64_t changeset_index = 0;
        std::int_fast64_t intrachangeset_progress = 0;
    };

    /// Returns the persisted progress that was last stored by
    /// set_cooked_progress().
    ///
    /// Initially, until explicitly modified, both
    /// `CookedProgress::changeset_index` and
    /// `CookedProgress::intrachangeset_progress` are zero.
    virtual CookedProgress get_cooked_progress() const = 0;

    /// Persistently stores the point of progress of the consumer of cooked
    /// changesets.
    ///
    /// As well as allowing for later retrieval, the specification of the point
    /// of progress of the consumer of cooked changesets also has the effect of
    /// trimming obsolete cooked changesets from the Realm file. Indeed, if this
    /// function is never called, but cooked changesets are continually being
    /// produced, then the Realm file will grow without bounds.
    ///
    /// Behavior is undefined if the specified index
    /// (CookedProgress::changeset_index) is lower than the index returned by
    /// get_cooked_progress().
    ///
    /// The intrachangeset progress field
    /// (CookedProgress::intrachangeset_progress) will be faithfully persisted,
    /// but will otherwise be treated as an opaque object by the history
    /// internals.
    virtual void set_cooked_progress(CookedProgress) = 0;

    /// Get the number of cooked changesets so far produced for this Realm. This
    /// is the number of cooked changesets that are currently in the Realm file
    /// plus the number of cooked changesets that have been trimmed off so far.
    virtual std::int_fast64_t get_num_cooked_changesets() const = 0;

    /// Fetch the cooked changeset at the specified index.
    ///
    /// Cooked changesets are made available in the order they are produced by
    /// the changeset cooker (ChangesetCooker).
    ///
    /// Behaviour is undefined if the specified index is less than the index
    /// (CookedProgress::changeset_index) returned by get_cooked_progress(), or
    /// if it is greater than, or equal to the toal number of cooked changesets
    /// (as returned by get_num_cooked_changesets()).
    ///
    /// The callee must append the bytes of the located cooked changeset to the
    /// specified buffer, which does not have to be empty initially.
    virtual void get_cooked_changeset(std::int_fast64_t index,
                                      util::AppendBuffer<char>&) const = 0;

    /// set_initial_state_realm_history_numbers() sets the history numbers for
    /// a new state Realm. The function is used when the server creates a new
    /// State Realm.
    ///
    /// The history object must be in a write transaction before the function
    /// call.
    virtual void set_initial_state_realm_history_numbers(version_type local_version,
                                                         sync::SaltedVersion server_version) = 0;

    /// set_initial_collision_tables() copies the collision tables from
    /// 'src_object_id_history_state' into the object id history state of this history.
    /// The current object_id_history_state must be empty. This function is used when
    /// the server creates a state Realm.
    ///
    /// The history object must be in a write transaction before the function
    /// call.
    virtual void set_initial_collision_tables(version_type local_version,
                                              const _impl::ObjectIDHistoryState& src_object_id_history_state) = 0;

    // virtual void set_client_file_ident_in_wt() sets the client file ident.
    // The history must be in a write transaction with version 'current_version'.
    virtual void set_client_file_ident_in_wt(version_type current_version,
                                             SaltedFileIdent client_file_ident) = 0;

    /// set_client_file_ident_and_downloaded_bytes() sets the salted client
    /// file ident and downloaded_bytes. The function is used when a state
    /// Realm has been downloaded from the server. The function creates a write
    /// transaction.
    virtual void set_client_file_ident_and_downloaded_bytes(SaltedFileIdent client_file_ident,
                                                            uint_fast64_t downloaded_bytes) = 0;

    /// set_client_reset_adjustments() is used by client reset to adjust the
    /// content of the history compartment. The shared group associated with
    /// this history object must be in a write transaction when this function
    /// is called.
    virtual void set_client_reset_adjustments(version_type current_version,
                                              SaltedFileIdent client_file_ident,
                                              sync::SaltedVersion server_version,
                                              uint_fast64_t downloaded_bytes,
                                              BinaryData uploadable_changeset) = 0;

    struct LocalChangeset {
        version_type version;
        ChunkedBinaryData changeset;
    };

    // get_next_local_changeset returns the first changeset with version
    // greater than or equal to 'begin_version'. 'begin_version' must be at
    // least 1.
    //
    // The history must be in a transaction when this function is called.
    // The return value is none if there are no such local changesets.
    virtual Optional<LocalChangeset> get_next_local_changeset(version_type current_version,
                                                              version_type begin_version) const = 0;

    /// Return an upload cursor as it would be when the uploading process
    /// reaches the snapshot to which the current transaction is bound.
    ///
    /// **CAUTION:** Must be called only while a transaction (read or write) is
    /// in progress via the SharedGroup object associated with this history
    /// object.
    virtual UploadCursor get_upload_anchor_of_current_transact() const = 0;

    /// Return the synchronization changeset of the current transaction as it
    /// would be if that transaction was committed at this time.
    ///
    /// The returned memory reference may be invalidated by subsequent
    /// operations on the Realm state.
    ///
    /// **CAUTION:** Must be called only while a write transaction is in
    /// progress via the SharedGroup object associated with this history object.
    virtual util::StringView get_sync_changeset_of_current_transact() const noexcept = 0;

protected:
    ClientHistory(const std::string& realm_path);
};


/// \brief Abstract interface for changeset cookers.
///
/// Note, it is completely up to the application to decide what a cooked
/// changeset is. History objects (instances of ClientHistory) are required to
/// treat cooked changesets as opaque entities. For an example of a concrete
/// changeset cooker, see TrivialChangesetCooker which defines the cooked
/// changesets to be identical copies of the raw changesets.
class ClientHistory::ChangesetCooker {
public:
    virtual ~ChangesetCooker() {}

    /// \brief An opportunity to produce a cooked changeset.
    ///
    /// When the implementation chooses to produce a cooked changeset, it must
    /// write the cooked changeset to the specified buffer, and return
    /// true. When the implementation chooses not to produce a cooked changeset,
    /// it must return false. The implementation is allowed to write to the
    /// buffer, and return false, and in that case, the written data will be
    /// ignored.
    ///
    /// \param prior_state The state of the local Realm on which the specified
    /// raw changeset is based.
    ///
    /// \param changeset, changeset_size The raw changeset.
    ///
    /// \param buffer The buffer to which the cooked changeset must be written.
    ///
    /// \return True if a cooked changeset was produced. Otherwise false.
    virtual bool cook_changeset(const Group& prior_state,
                                const char* changeset, std::size_t changeset_size,
                                util::AppendBuffer<char>& buffer) = 0;
};


class ClientHistory::Config {
public:
    Config() {}

    /// Must be set to true if, and only if the created history object
    /// represents (is owned by) the sync agent of the specified Realm file. At
    /// most one such instance is allowed to participate in a Realm file access
    /// session at any point in time. Ordinarily the sync agent is encapsulated
    /// by the sync::Client class, and the history instance representing the
    /// agent is created transparently by sync::Client (one history instance per
    /// sync::Session object).
    bool owner_is_sync_agent = false;

    /// If a changeset cooker is specified, then the created history object will
    /// allow for a cooked changeset to be produced for each changeset of remote
    /// origin; that is, for each changeset that is integrated during the
    /// execution of ClientHistory::integrate_remote_changesets(). If no
    /// changeset cooker is specified, then no cooked changesets will be
    /// produced on behalf of the created history object.
    ///
    /// ClientHistory::integrate_remote_changesets() will pass each incoming
    /// changeset to the cooker after operational transformation; that is, when
    /// the chageset is ready to be applied to the local Realm state.
    std::shared_ptr<ChangesetCooker> changeset_cooker;
};

/// \brief Create a "sync history" implementation of the realm::Replication
/// interface.
///
/// The intended role for such an object is as a plugin for new
/// realm::SharedGroup objects.
std::unique_ptr<ClientHistory> make_client_history(const std::string& realm_path,
                                                   ClientHistory::Config = {});



// Implementation

inline ClientHistoryBase::ClientHistoryBase(const std::string& realm_path) :
    InstructionReplication{realm_path} // Throws
{
}

inline auto ClientHistoryBase::generate_changeset_timestamp() noexcept -> timestamp_type
{
    namespace chrono = std::chrono;
    // Unfortunately, C++11 does not specify what the epoch is for
    // `chrono::system_clock` (or for any other clock). It is believed, however,
    // that there is a de-facto standard, that the Epoch for
    // `chrono::system_clock` is the Unix epoch, i.e., 1970-01-01T00:00:00Z. See
    // http://stackoverflow.com/a/29800557/1698548. Additionally, it is assumed
    // that leap seconds are not included in the value returned by
    // time_since_epoch(), i.e., that it conforms to POSIX time. This is known
    // to be true on Linux.
    //
    // FIXME: Investigate under which conditions OS X agrees with POSIX about
    // not including leap seconds in the value returned by time_since_epoch().
    //
    // FIXME: Investigate whether Microsoft Windows agrees with POSIX about
    // about not including leap seconds in the value returned by
    // time_since_epoch().
    auto time_since_epoch = chrono::system_clock::now().time_since_epoch();
    std::uint_fast64_t millis_since_epoch =
        chrono::duration_cast<chrono::milliseconds>(time_since_epoch).count();
    // `offset_in_millis` is the number of milliseconds between
    // 1970-01-01T00:00:00Z and 2015-01-01T00:00:00Z not counting leap seconds.
    std::uint_fast64_t offset_in_millis = 1420070400000ULL;
    return timestamp_type(millis_since_epoch - offset_in_millis);
}

inline ClientHistory::ClientHistory(const std::string& realm_path) :
    ClientHistoryBase{realm_path} // Throws
{
}

} // namespace sync
} // namespace realm

#endif // REALM_SYNC_HISTORY_HPP
