@extends('layouts.app')

@section('title', 'Student Details')

@section('content')
    <h1 class="mb-4">Student Details</h1>

    <div class="card">
        <div class="card-body">
            <h5 class="card-title">{{ $student->nama }}</h5>
            <p class="card-text"><strong>NIS:</strong> {{ $student->nis }}</p>
            <p class="card-text"><strong>Alamat:</strong> {{ $student->alamat }}</p>
            <p class="card-text"><strong>No HP:</strong> {{ $student->no_hp }}</p>
            <p class="card-text"><strong>Jenis Kelamin:</strong> {{ $student->jenis_kelamin }}</p>
            <p class="card-text"><strong>Hobi:</strong> {{ $student->hobi }}</p>
        </div>
    </div>

    <div class="mt-3">
        <a href="{{ route('students.edit', $student) }}" class="btn btn-warning">Edit</a>
        <form action="{{ route('students.destroy', $student) }}" method="POST" class="d-inline">
            @csrf
            @method('DELETE')
            <button type="submit" class="btn btn-danger" onclick="return confirm('Are you sure you want to delete this student?')">Delete</button>
        </form>
        <a href="{{ route('students.index') }}" class="btn btn-secondary">Back to List</a>
    </div>
@endsection
