package one

import (
	"testing"

	"github.com/stretchr/testify/require"
	"github.com/wafer-bw/gocovtesting/three"
)

func TestOne(t *testing.T) {
	require.Equal(t, 1, One())
}

// TestThree cross-package
func TestThree(t *testing.T) {
	require.Equal(t, 3, three.Three())
}
