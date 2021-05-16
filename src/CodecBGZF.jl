module CodecBGZF

export
    BGZFCompressorStream,
    BGZFDecompressorStream,
    BGZFException,
    CodecBGZFError,
    CodecBGZFErrors,
    VirtualOffset,
    offsets,
    gzi

using LibDeflate
import LibDeflate: GzipExtraField
using TranscodingStreams

import TranscodingStreams:
    TranscodingStreams,
    TranscodingStream,
    Memory,
    Error

import Base.Threads.@spawn

const DE_COMPRESSOR = Union{Compressor, Decompressor}


"""
    Module CodecBGZFErrors
Dummy module to contain the variants of the `CodecBGZFError` enum.
"""
module CodecBGZFErrors

    @enum CodecBGZFError::UInt8 begin
        NO_GZIP_EXTRA_FIELD_BSIZE
    end

    @doc """
        CodecBGZFError
    A `UInt8` enum representing that CodecBGZF encountered an error.
    Successful operations will never return a `CodecBGZFError`.
    """
    CodecBGZFError

    export CodecBGZFError
end # module

using .CodecBGZFErrors


"""
    BGZFException(message::String)

BGZF de/compressor errored with `message` when processing data."
"""
struct BGZFException <: Exception
    message
end

"""
    LibDeflateException(message)

LibDeflateException errored with `message` when processing data."
"""
struct LibDeflateException <: Exception
    message
end

function bitload(T::Type{<:Base.BitInteger}, data::Vector{UInt8}, p::Integer)
    ltoh(unsafe_load(Ptr{T}(pointer(data, p))))
end

function bitstore(v::Base.BitInteger, data::Vector{UInt8}, p::Integer)
    unsafe_store!(Ptr{typeof(v)}(pointer(data, p)), htol(v))
end

@noinline bgzferror(s::String) = throw(BGZFException(s))

include("virtualoffset.jl")
include("block.jl")
include("bgzfstream.jl")

end # module
